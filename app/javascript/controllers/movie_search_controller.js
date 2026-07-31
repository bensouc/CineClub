import { Controller } from "@hotwired/stimulus"

const SEARCH_FAILED = "La recherche a échoué"

// Drives the movie search box on an event page.
//
// The TMDB call itself happens server-side (MoviesController#search) so the API
// key never reaches the browser; this controller only renders what comes back.
export default class extends Controller {
  static targets = ["query", "results"]
  static values = { searchUrl: String, addUrl: String }

  async search(event) {
    event.preventDefault()

    const query = this.queryTarget.value.trim()
    if (query === "") {
      this.#showMessage("Le champ doit être rempli")
      return
    }

    this.#showMessage("Recherche…")
    this.element.scrollIntoView()

    let response
    let payload
    try {
      response = await fetch(`${this.searchUrlValue}?query=${encodeURIComponent(query)}`, {
        headers: { Accept: "application/json" }
      })
      payload = await response.json()
    } catch (error) {
      this.#showMessage(SEARCH_FAILED)
      return
    }

    if (!response.ok) {
      this.#showMessage(payload?.error ?? SEARCH_FAILED)
      return
    }

    this.#showResults(payload.results ?? [])
  }

  #showResults(results) {
    if (results.length === 0) {
      this.#showMessage("Aucun résultat correspondant")
      return
    }

    this.resultsTarget.replaceChildren(...results.map((result) => this.#resultItem(result)))
  }

  // Only the TMDB id travels back to the server, so titles containing "&" or
  // "#" can no longer corrupt the URL.
  #resultItem(result) {
    const poster = document.createElement("img")
    poster.src = result.poster_url
    poster.alt = result.title
    poster.loading = "lazy"
    poster.className = "aspect-2/3 w-full object-cover"

    const caption = document.createElement("span")
    caption.textContent = result.year ? `${result.title} · ${result.year}` : result.title
    caption.className = "block truncate p-1.5 text-[11px] font-medium text-muted"

    const link = document.createElement("a")
    link.href = `${this.addUrlValue}?tmdb_id=${encodeURIComponent(result.tmdb_id)}`
    link.dataset.turboMethod = "post"
    link.title = caption.textContent
    link.className =
      "block overflow-hidden rounded-xl border border-line bg-card shadow-sm transition hover:-translate-y-0.5 hover:shadow-md"
    link.append(poster, caption)

    const item = document.createElement("li")
    item.appendChild(link)
    return item
  }

  // A text node rather than innerHTML: the messages are ours, but the habit keeps
  // anything TMDB-sourced from ever being parsed as markup. .noresult is a fixed
  // 200px centred box, so the text wraps on its own without hand-placed <br>.
  #showMessage(text) {
    const message = document.createElement("li")
    message.textContent = text
    message.className =
      "col-span-3 rounded-xl border border-dashed border-line py-8 text-center text-sm text-muted"

    this.resultsTarget.replaceChildren(message)
  }
}
