import { Controller } from "@hotwired/stimulus"

// Copies an invitation link so it can be pasted straight into the group chat.
export default class extends Controller {
  static targets = ["label"]
  static values = { text: String }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.textValue)
      this.#flash("Lien copié !")
    } catch {
      this.#flash("Copie impossible")
    }
  }

  #flash(message) {
    if (!this.hasLabelTarget) return

    const original = this.labelTarget.textContent
    this.labelTarget.textContent = message
    setTimeout(() => (this.labelTarget.textContent = original), 2000)
  }
}
