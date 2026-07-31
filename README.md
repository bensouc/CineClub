CineClub is a responsive web app for mobile first, dedicated to movie lovers and Cinéclub associates.
It allows users to select and vote for the next Cinéclub session.

Landing Page:

<img src="https://user-images.githubusercontent.com/85955716/172575798-f81da706-f136-4ad3-b109-a65d614ea37f.jpg" width="250">

Powered by [TMDB APIs](https://developer.themoviedb.org/), users can look for a movie.
Results are shown in the show page without a page reload.


<img src="https://user-images.githubusercontent.com/85955716/172576872-30d3ed1b-382c-4a05-9903-e964b30cfb63.jpg" width="250">

When added to an event, the movie's trailer link is looked up through the TMDB API, helping other users in their votes.

<img src="https://user-images.githubusercontent.com/85955716/172577222-c3e3ef8b-92d1-4276-8fc5-02b357516281.jpg" width="250">

Users can vote, change their votes, view others' votes, remove an added movie:

<img src="https://user-images.githubusercontent.com/85955716/172582106-7823178f-7729-4dfe-9ad5-bf6698d576fd.jpg" width="250">

---

## Stack

| | |
|---|---|
| Ruby | 3.3.10 (see `.ruby-version`) |
| Rails | 8.1 |
| Database | PostgreSQL |
| Assets | Propshaft + [dartsass-rails](https://github.com/rails/dartsass-rails) (SCSS) |
| JavaScript | [Importmap](https://github.com/rails/importmap-rails) + Turbo + Stimulus — **no Node, no bundler** |
| CSS framework | Bootstrap 5.3, SCSS source vendored in `vendor/assets/stylesheets/bootstrap` |
| Auth | Devise |

Bootstrap's and Popper's JavaScript are vendored under `vendor/javascript` and
pinned in `config/importmap.rb`, so nothing is fetched from a CDN at runtime.

## Getting started

```bash
bin/setup            # bundle, prepare the database, start the server
```

`bin/setup` needs `config/master.key`, which is **not** in the repository — ask a
teammate for it and drop it in `config/`. It decrypts `config/credentials.yml.enc`,
which holds `secret_key_base` and the TMDB API key.

To run the server and the SCSS watcher together:

```bash
bin/dev              # foreman: rails server + dartsass:watch
```

### Credentials

```bash
EDITOR="code --wait" bin/rails credentials:edit
```

```yaml
secret_key_base: ...
tmdb:
  api_key: <your TMDB v3 API key>
```

Get a key at https://www.themoviedb.org/settings/api.

## How the TMDB integration works

The API key never reaches the browser.

1. The search box (`movie_search_controller.js`) calls **`GET /movies/search?query=…`**
   on our own server. That endpoint requires a signed-in user.
2. `MoviesController#search` delegates to `TmdbClient` (`app/services/tmdb_client.rb`),
   which reads the key from credentials, calls TMDB over HTTPS with timeouts, and
   returns a normalised list of `{tmdb_id, title, poster_url, year}`.
3. Adding a movie posts **only its `tmdb_id`** to `POST /events/:id`. The server
   fetches the title, poster, genres, release date and trailer from TMDB itself,
   so nothing user-supplied is written to the `movies` table.

If TMDB is down or misconfigured, search answers `502` with a readable message
and adding a movie redirects back with a flash — neither raises a 500.

## Managing events

Creating and editing a "soirée" is restricted to users with `users.admin = true`.
Promote someone with:

```bash
bin/rails runner 'User.find_by!(email: "you@example.com").update!(admin: true)'
```

Admins then get a **+** button in the bottom-right menu and a "Modifier la soirée"
link on each event page.

## Tests

```bash
bin/rails test
```

The suite never touches the network: WebMock is enabled in `test/test_helper.rb`
and every TMDB call is stubbed (`stub_tmdb`).

## Déploiement (Coolify sur VPS OVH)

L'image ne contient **aucune étape Node** : le JS passe par Importmap
(`vendor/javascript`, versionné) et le CSS est compilé par le binaire livré dans
la gem `tailwindcss-ruby`. Le `Gemfile.lock` embarque les plateformes Linux
(`x86_64-linux-gnu`, `aarch64-linux-gnu`), donc le binaire Tailwind est bien
résolu dans le conteneur.

### Configuration Coolify

| Réglage | Valeur |
|---|---|
| Build Pack | Dockerfile |
| Port exposé | `3000` |
| Health check | `/up` |
| Pre-deployment command | `./bin/rails db:prepare` |

La commande pre-deploy est **indispensable** : les migrations ne tournent pas
dans l'entrypoint, pour ne s'exécuter qu'une fois par déploiement plutôt qu'à
chaque démarrage de conteneur.

### Variables d'environnement

| Variable | Rôle |
|---|---|
| `RAILS_MASTER_KEY` | contenu de `config/master.key` — déchiffre les credentials (clé TMDB, `secret_key_base`) |
| `DATABASE_URL` | fournie par le service PostgreSQL attaché dans Coolify |
| `APP_HOST` | domaine public, utilisé pour les liens dans les emails |

`RAILS_ENV`, `PORT`, `RAILS_LOG_TO_STDOUT` et `RAILS_SERVE_STATIC_FILES` sont
déjà fixés dans le Dockerfile — inutile de les répéter côté Coolify.

L'app tourne avec `force_ssl` et `assume_ssl`, ce qui suppose un proxy qui
termine le TLS et renseigne `X-Forwarded-Proto`. C'est ce que fait le Traefik de
Coolify. En frappant le conteneur directement en HTTP, tout est redirigé vers
HTTPS sauf `/up`, volontairement exclu pour que le health check fonctionne.

### Premier déploiement

Aucun compte n'est créé automatiquement. Une fois la première mise en ligne
faite, amorcez l'administrateur depuis un terminal Coolify :

```bash
ADMIN_EMAIL=vous@exemple.fr ADMIN_PASSWORD='...' bin/rails db:seed
```

Tous les comptes suivants passent par un lien d'invitation généré depuis
`/invitations`.

### Build en local

```bash
colima start                    # le runtime Docker de cette machine
docker build -t cineclub .
```
