// app/javascript/controllers/click_row_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.element.style.cursor = "pointer"
  }

  navigate(event) {
    const selection = window.getSelection()
    const isTextSelected = selection && selection.toString().length > 0

    // If text is selected, don't follow the link
    if (isTextSelected) return

    if (this.urlValue) {
      window.open(this.urlValue, "_blank")
    }
  }
}
