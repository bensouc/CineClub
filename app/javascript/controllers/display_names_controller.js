import { Controller } from "stimulus"

  export default class extends Controller {
    static targets = ["votes"]

    connect() {
      console.log('hello')
    }
    displayVotes() {
      console.log("display")
      this.votesTarget.classList.remove("d-none")

    }
    hideVotes() {
      console.log("remove")
      this.votesTarget.classList.add("d-none")
    }
  }
