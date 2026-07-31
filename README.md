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

## Deployment (Fly.io)

The `Dockerfile` has no Node stage. Assets are compiled at build time by
`assets:precompile`, which pulls in `dartsass:build`.

```bash
fly secrets set RAILS_MASTER_KEY="$(cat config/master.key)"
fly deploy
```

`DATABASE_URL` is provided by the attached Postgres cluster. `/up` is the health
check endpoint.
