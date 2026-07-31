import { Controller } from "@hotwired/stimulus"

// Drives a native <dialog>. Replaces Bootstrap's modal plugin: the browser
// already gives us the backdrop, focus trapping and Escape-to-close.
export default class extends Controller {
  static targets = ["modal"]

  open() {
    this.modalTarget.showModal()
  }

  close() {
    this.modalTarget.close()
  }
}
