import { Controller } from "@hotwired/stimulus"

// Dismissable flash message, optionally on a timer.
export default class extends Controller {
  static values = { after: Number }

  connect() {
    if (this.hasAfterValue && this.afterValue > 0) {
      this.timeout = setTimeout(() => this.close(), this.afterValue)
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  close() {
    this.element.remove()
  }
}
