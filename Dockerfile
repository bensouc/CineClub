# =============================================================================
# Dockerfile — image de production de CinéClub, déployée via Coolify.
# =============================================================================
# Build multi-étapes : on compile dans une image jetable ("build") et l'image
# finale ne contient que ce qu'il faut pour FAIRE TOURNER l'app.
#
#   1. base  : socle commun (Ruby + variables d'env)
#   2. build : gems + assets compilés          (JETÉE à la fin)
#   3. final : base + le résultat copié depuis "build"
#
# Pas d'étape Node, contrairement à Ensemble : le JS passe par Importmap
# (vendor/javascript, versionné) et le CSS est compilé par le binaire livré
# dans la gem tailwindcss-ruby. Aucun yarn/npm n'est nécessaire.
#
# Les MIGRATIONS ne tournent pas ici : elles passent par la commande pre-deploy
# de Coolify (voir README), pour ne s'exécuter qu'une fois par déploiement.
# -----------------------------------------------------------------------------

ARG RUBY_VERSION=3.3.10


# -----------------------------------------------------------------------------
# Étape 1 — base
# -----------------------------------------------------------------------------
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

# PORT doit être fixé ici : Puma retomberait sinon sur 3000 par défaut, et si
# EXPOSE annonçait autre chose, Traefik frapperait à une porte fermée.
# RAILS_SERVE_STATIC_FILES est actif car Propshaft sert les assets digérés —
# il n'y a pas de nginx dans le conteneur.
ENV RAILS_ENV="production" \
    PORT="3000" \
    RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="1" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"


# -----------------------------------------------------------------------------
# Étape 2 — build (jetable)
# -----------------------------------------------------------------------------
FROM base AS build

# Outils de compilation, uniquement ici :
#  - build-essential : gems natives (pg…)
#  - libpq-dev       : en-têtes PostgreSQL pour la gem "pg"
#  - libyaml-dev     : psych/YAML
#  - pkg-config      : aide les gems natives à trouver les libs système
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libyaml-dev \
      pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Gemfile d'abord : tant qu'il ne bouge pas, Docker réutilise cette couche.
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

# assets:precompile déclenche tailwindcss:build. app/assets/builds/ est gitignoré,
# donc vide dans le clone de Coolify : cette étape est ce qui produit réellement
# la feuille de style. SECRET_KEY_BASE_DUMMY évite d'avoir besoin du vrai
# master.key au build — il n'est fourni qu'au runtime.
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# -----------------------------------------------------------------------------
# Étape 3 — final
# -----------------------------------------------------------------------------
FROM base

# Paquets de RUNTIME :
#  - libpq5            : client PostgreSQL (gem pg)
#  - postgresql-client : psql/pg_dump pour le debug et la maintenance
#  - curl              : health check
#  - tini              : init minimal en PID 1, moissonne les process zombies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libpq5 \
      postgresql-client \
      tini && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# On ne tourne pas en root.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p log tmp storage tmp/pids && \
    chown -R rails:rails log tmp storage
USER 1000:1000

ENTRYPOINT ["/usr/bin/tini", "--", "/rails/bin/docker-entrypoint"]

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
