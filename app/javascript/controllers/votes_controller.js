import { Controller } from "@hotwired/stimulus"

// Shows the list of voters over the poster of a single choice card.
export default class extends Controller {
  static targets = ["panel"]

  toggle() {
    this.panelTarget.classList.toggle("hidden")
    this.panelTarget.classList.toggle("flex")
  }
}
