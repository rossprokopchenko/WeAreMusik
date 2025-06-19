// app/javascript/controllers/cover_art_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["coverContainer"]

  connect() {
    this.loadImage()
  }

  loadImage() {
    const url = this.data.get("coverUrl")
    if (!url) return

    // Create the image element but keep skeleton visible initially
    const img = new Image()
    img.src = url
    img.className = "rounded-xl w-full object-cover absolute inset-0"
    img.style.opacity = "0"
    img.alt = "Cover Art"

    img.addEventListener("load", () => {
      // Remove skeleton div
      const skeleton = this.coverContainerTarget.querySelector(".cover-skeleton")
      if (skeleton) skeleton.remove()

      // Append the image
      this.coverContainerTarget.appendChild(img)

      // Fade in the image smoothly
      requestAnimationFrame(() => {
        img.style.transition = "opacity 0.5s ease"
        img.style.opacity = "1"
      })
    })

    // Positioning container relative for absolute image
    this.coverContainerTarget.style.position = "relative"
  }
}
