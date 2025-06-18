import { Controller } from "@hotwired/stimulus"

// Helper: lighten/darken RGB by % (e.g. -0.3 = darker)
function shadeRGBColor([r, g, b], percent) {
  return [
    Math.min(255, Math.max(0, r + r * percent)),
    Math.min(255, Math.max(0, g + g * percent)),
    Math.min(255, Math.max(0, b + b * percent)),
  ].map(v => Math.round(v))
}

function rgbString([r, g, b]) {
  return `rgb(${r}, ${g}, ${b})`
}

export default class extends Controller {
  static targets = ["circle", "hiddenImage"]

  connect() {
    const image = this.hiddenImageTarget

    if (image.complete) {
      this.setGradient(image)
    } else {
      image.addEventListener("load", () => this.setGradient(image))
    }
  }

  setGradient(image) {
    const colorThief = new ColorThief()
  
    try {
      const baseColor = colorThief.getColor(image)
  
      const darker = rgbString(shadeRGBColor(baseColor, -0.3))
      const mid = rgbString(baseColor)
      const lighter = rgbString(shadeRGBColor(baseColor, 0.3))
  
      const gradient = `radial-gradient(circle, ${lighter} 0%, ${mid} 50%, ${darker} 100%)`
  
      this.circleTarget.style.backgroundImage = gradient
    } catch (e) {
      console.warn("Could not extract color:", e)
    }
  }
  
}
