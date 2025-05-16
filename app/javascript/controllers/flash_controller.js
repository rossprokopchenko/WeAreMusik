import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // This runs when the controller is connected to the DOM element
    setTimeout(() => {
      this.element.classList.add("opacity-0")
      setTimeout(() => {
        this.element.remove()
      }, 500) // matches the CSS fade duration
    }, 3000) // wait 3 seconds before fading out
  }
}