// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static timeout = null

  submit(event) {
    clearTimeout(this.constructor.timeout)
    this.constructor.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 100)
  }

  clear() {
    const input = document.querySelector(".search-input")
    if (input) input.value = ""
  }
}