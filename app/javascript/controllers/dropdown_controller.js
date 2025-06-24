import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "label"]

  connect() {
    this.boundOutsideClick = this.closeIfClickedOutside.bind(this)
    document.addEventListener("click", this.boundOutsideClick)

    // Get current search type from URL param or localStorage or default
    const params = new URLSearchParams(window.location.search)
    const paramSearchType = params.get("search_type")
    const savedSearchType = localStorage.getItem("searchType")
    const initialType = paramSearchType || savedSearchType || "tracks"

    // Update visible label with capitalized text
    this.labelTarget.textContent = initialType.charAt(0).toUpperCase() + initialType.slice(1)

    // Highlight the correct button
    this.menuTarget.querySelectorAll("button").forEach(button => {
      if (button.dataset.value === initialType) {
        button.classList.add("bg-gray-700")
      } else {
        button.classList.remove("bg-gray-700")
      }
    })

    // Make sure menu is hidden initially
    this.menuTarget.classList.add("hidden")
  }

  disconnect() {
    document.removeEventListener("click", this.boundOutsideClick)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  select(event) {
    const value = event.currentTarget.dataset.value
    this.labelTarget.textContent = value.charAt(0).toUpperCase() + value.slice(1)

    // Remove highlight from all items
    this.menuTarget.querySelectorAll("button").forEach(button => {
      button.classList.remove("bg-gray-700")
    })

    // Add highlight to the selected item
    event.currentTarget.classList.add("bg-gray-700")

    // Notify the search controller
    const searchController = this.application.getControllerForElementAndIdentifier(
      this.element.closest("[data-controller='search']"),
      "search"
    )

    if (searchController) {
      searchController.updateSearchType(value)
    }

    this.menuTarget.classList.add("hidden")
  }

  closeIfClickedOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
