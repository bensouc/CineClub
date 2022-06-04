import { Controller } from "stimulus"

  export default class extends Controller {
    static targets = ["votes"]

    connect() {
      console.log('hello')
    }
    displayVotes() {
      console.log(this)
      this.votesTarget.classList.remove("d-none")

    }
    hideVotes() {
      this.votesTarget.classList.add("d-none")
    }
  }
