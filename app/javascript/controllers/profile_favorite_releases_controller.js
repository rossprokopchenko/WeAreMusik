import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["extraRelease", "seeAllButton"]

  connect() {
    this.expanded = false
    this.updateView()
  }

  toggle() {
    this.expanded = !this.expanded
    this.updateView()
  }

  updateView() {
    this.extraReleaseTargets.forEach(el => {
      el.style.display = this.expanded ? "" : "none"
    })

    this.seeAllButtonTarget.textContent = this.expanded ? "Show less" : "See all"
  }
}
