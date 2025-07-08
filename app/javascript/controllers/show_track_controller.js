import { Controller } from "@hotwired/stimulus"

// Stimulus controller for toggling external links dropdown on track items
export default class extends Controller {
  static targets = ["externalLinks"]

  toggle() {
    this.externalLinksTarget.classList.toggle("hidden")
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.externalLinksTarget.classList.add("hidden")
    }
  }

  connect() {
    document.addEventListener("click", this.closeBound = this.close.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.closeBound)
  }
}
