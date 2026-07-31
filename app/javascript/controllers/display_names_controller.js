import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["votes"]

  displayVotes() {
    this.votesTarget.classList.remove("d-none")
  }

  hideVotes() {
    this.votesTarget.classList.add("d-none")
  }
}
