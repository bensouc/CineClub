import { Controller } from "stimulus"

import * as Routes from 'routes';

export default class extends Controller {
  static targets = ["query", "results", "add_movie"]

  // connect() {

  //   console.log("searc movie controller connected")
  // }

  display_results(event) {
    event.preventDefault() // <-- to prevent <form>'s native behaviour
    this.resultsTarget.innerHTML = ""

    const query = this.queryTarget.value
    const api_key = process.env.TMDB_API_KEY

    if (query == '' || query == 'Titre') {
      const movieTag =
        `<div class="noresult">
          <h5>Le champ doit<br> être rempli</h5>
        </div>`
      this.resultsTarget.insertAdjacentHTML("beforeend", movieTag)
    }
    else {
      fetch(`https://api.themoviedb.org/3/search/movie?api_key=${api_key}&query=${query}&language=fr`)
      // 5d25d045ccb74424de93b9f3878f1b6c
        .then(response => response.json())
        .then(data => this.insertMovies(data))
      }
      document.getElementById("search-bar").scrollIntoView();
  }

  insertMovies(data) {
    if (data.total_results == 0) {
      const movieTag =
        `<div class="noresult">
          <h5>Aucun résultat <br> correspondant</h5>
        </div>`
      this.resultsTarget.insertAdjacentHTML("beforeend", movieTag)
    }
    else {

      // get event id
      const baseUrl = document.URL
      const event_id = baseUrl.substring(baseUrl.lastIndexOf('events/') + 7)
      const clean_event_id = (event_id.match(/[0-9]+/))[0]
      data.results.forEach((result) => {
        const movieTag =
          `<li class="m-3">
            <a rel="nofollow" data-method="post" href="/events/${clean_event_id}?title=${result.title}
&tmdb_poster_url=${result.poster_path}&trailer_url=&year=${result.release_date}
&tmdb_id=${result.id}&tmdb_genre_id=${result.genre_ids}">
                <img src= https://image.tmdb.org/t/p/w300${result.poster_path} alt="" width="230"
                data-action ="click->movie-search#add_movie" data-movie-search-target='add_movie'
            </a>
            </li>`
        this.resultsTarget.insertAdjacentHTML("beforeend", movieTag)
      })
    }
  }

  // add_movie() {
  //   console.log(this.add_movieTarget.getAttribute("info"))
  //   console.log(event_id)
  //   var custom_url = { id: `{event_id}`, to_param: `${this.add_movieTarget.getAttribute("info")}` };
  //   var custom_url2 = {
  //     id: event_id
  //   }

  //   // window.location.href = Routes.events_path(event_id)
  //   // window.location.href = Routes.event_choices(event_id,{info: this.add_movieTarget.getAttribute("info")})
  //   // creér un nouveau movie si il n'existe pas (tmdb_id)

  //   // creer un nouveau choices avec ce movie

  // }

}
