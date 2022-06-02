import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["query", "results"]

  connect() {
    console.log('results conntecté')
  }

  display_results(event) {
    event.preventDefault() // <-- to prevent <form>'s native behaviour
    this.resultsTarget.innerHTML = ""
    // console.log(this.queryTarget.value)
    const query = this.queryTarget.value
    if (query == '' || query == 'Titre') {
      const movieTag =
        `<div class="noresult">
          <h5>Le champ doit<br> être rempli</h5>
        </div>`
      this.resultsTarget.insertAdjacentHTML("beforeend", movieTag)
    }
else
    {fetch(`https://api.themoviedb.org/3/search/movie?api_key=5d25d045ccb74424de93b9f3878f1b6c&query=${query}&language=fr`)
      .then(response => response.json())
      .then(data => this.insertMovies(data))}
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
      data.results.forEach((result) => {
        const movieTag =
          `<li class="m-3">
              <img src="https://image.tmdb.org/t/p/w300${result.poster_path}" alt="" width="230" data-action ='click->movie-search#add_movie'
              info={  title: ${result.title},
                      poster_url: https://image.tmdb.org/t/p/w300${result.poster_path},
                      trailer_url:,
                      year: ${result.release_date},
                      tmdb_id: ${result.id},
                      tmdb_genre_id : ${result.genre_ids}
                    }>
          </li>`
        this.resultsTarget.insertAdjacentHTML("beforeend", movieTag)
      })
    }
  }

  add_movie(event) {
    console.log("add movie")
  }

}
