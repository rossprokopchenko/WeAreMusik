import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["extraArtist", "seeAllButton"]

  connect() {
    this.expanded = false
    this.updateView()
  }

  toggle() {
    this.expanded = !this.expanded
    this.updateView()
  }

  updateView() {
    this.extraArtistTargets.forEach(el => {
      el.style.display = this.expanded ? "" : "none"
    })

    this.seeAllButtonTarget.textContent = this.expanded ? "Show less" : "See all"
  }
}
