
import { Controller } from "@hotwired/stimulus"

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
    document.addEventListener("click", this.close.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.close.bind(this))
  }
}
