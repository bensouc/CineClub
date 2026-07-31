# syntax=docker/dockerfile:1
# check=error=true

# Deployable image for CineClub. There is no Node stage: the JavaScript ships
# through Importmap (vendor/javascript) and the CSS is compiled by dart-sass,
# which dartsass-rails downloads as a Ruby gem.
#
# Build:  docker build -t cineclub .
# Run:    docker run -d -p 8080:8080 -e RAILS_MASTER_KEY=<config/master.key> -e DATABASE_URL=<url> cineclub

ARG RUBY_VERSION=3.3.10
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Packages needed at run time only.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"


# --- build stage: gems, bootsnap cache and precompiled assets ---------------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

# assets:precompile pulls in dartsass:build, which needs the Rails environment.
# SECRET_KEY_BASE_DUMMY lets it boot without the real master key, which we
# deliberately do not bake into the image.
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# --- final image ------------------------------------------------------------
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run as an unprivileged user.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 8080
CMD ["./bin/rails", "server"]
