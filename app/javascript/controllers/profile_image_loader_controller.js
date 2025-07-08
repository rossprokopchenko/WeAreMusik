// app/javascript/controllers/image_loader_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.loadImage()
  }

  loadImage() {
    const url = this.data.get("url")
    if (!url) return

    const styleType = this.data.get("style") || "cover" // default style: 'cover' like cover-art

    const img = new Image()
    img.src = url
    img.alt = this.data.get("alt") || "Image"
    img.className = "rounded-xl"

    // Apply styles depending on the style type
    if (styleType === "artist") {
      // Artist image style (zoomed center, height 100%)
      img.style.position = "absolute"
      img.style.top = "50%"
      img.style.left = "50%"
      img.style.height = "100%"
      img.style.width = "auto"
      img.style.transform = "translate(-50%, -50%)"
      img.style.objectFit = "cover"
    } else {
      // Cover art style (full width, object-fit cover)
      img.style.position = "absolute"
      img.style.inset = "0"
      img.style.width = "100%"
      img.style.height = "100%"
      img.style.objectFit = "cover"
    }

    img.style.transition = "opacity 0.5s ease"
    img.style.opacity = "0"

    img.addEventListener("load", () => {
      const skeleton = this.containerTarget.querySelector(".cover-skeleton")
      if (skeleton) skeleton.remove()

      this.containerTarget.appendChild(img)

      requestAnimationFrame(() => {
        img.style.opacity = "1"
      })
    })

    this.containerTarget.style.position = "relative"
    this.containerTarget.style.overflow = "hidden"
  }
}
