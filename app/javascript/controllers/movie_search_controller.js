import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["query","results"]

  connect() {
    console.log('results conntecté')
  }

  display_results(event) {
    event.preventDefault() // <-- to prevent <form>'s native behaviour
    this.resultsTarget.innerHTML = ""
    // console.log(this.queryTarget.value)
    const query = this.queryTarget.value

    fetch(`https://api.themoviedb.org/3/search/movie?api_key=5d25d045ccb74424de93b9f3878f1b6c&query=${query}&language=fr`)
    .then(response => response.json())
    .then(data => this.insertMovies(data))
  }

  insertMovies(data) {
    data.results.forEach((result) => {
      const movieTag =
      `<li class="list-group-item border-0">
      <img src="https://image.tmdb.org/t/p/w300${result.poster_path}" alt="" width="230" data-action ='click->movie-search#add_movie'>
      </li>`
      this.resultsTarget.insertAdjacentHTML("beforeend", movieTag)
    })
  }

  add_movie(event){
    console.log("add movie")
  }

}
