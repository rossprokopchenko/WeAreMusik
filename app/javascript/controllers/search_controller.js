import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "menu", "filterCanonical"]

  connect() {
    this.boundClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundClickOutside)
  
    const params = new URLSearchParams(window.location.search)
    const paramSearchType = params.get("search_type")
    const savedSearchType = localStorage.getItem("searchType")
    const initialType = paramSearchType || savedSearchType || "tracks"
  
    this.updateSearchType(initialType)
  
    // Ensure canonical filter button is enabled visually on load
    if (this.hasFilterCanonicalTarget) {
      const btn = this.filterCanonicalTarget
      btn.classList.add("border-green-400", "text-green-400")
      btn.classList.remove("border-red-400", "text-red-400")
      const icon = btn.querySelector("i")
      icon.classList.add("bi-check-lg")
      icon.classList.remove("bi-x-lg")
    }
  
    this.updateTable()
  }
  

  disconnect() {
    document.removeEventListener("click", this.boundClickOutside)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget?.classList.add("hidden")
    }
  }

  updateSearchType(type) {
    localStorage.setItem("searchType", type)
  
    const url = new URL(window.location)
  
    if (window.location.pathname === "/search") {
      url.searchParams.set("search_type", type)
    } else if (url.searchParams.has("search_type")) {
      url.searchParams.delete("search_type")
    }
  
    window.history.replaceState(null, "", url)
  
    this.updateTable()
  }

  search(event) {
    clearTimeout(this.constructor.timeout)
    this.constructor.timeout = setTimeout(() => {
      this.updateTable()
    }, 200)
  }

  toggleFilter(event) {
    const button = event.currentTarget
    const icon = button.querySelector("i")
    const isEnabled = button.classList.contains("border-green-400")
  
    if (isEnabled) {
      // Disable: border red, icon changes to X, icon color red
      button.classList.remove("border-green-400")
      button.classList.add("border-red-400")
      icon.classList.remove("bi-check-lg")
      icon.classList.add("bi-x-lg")
      // Make icon color red
      icon.classList.remove("text-green-400")
      icon.classList.add("text-red-400")
    } else {
      // Enable: border green, icon check, icon color green
      button.classList.remove("border-red-400")
      button.classList.add("border-green-400")
      icon.classList.remove("bi-x-lg")
      icon.classList.add("bi-check-lg")
      // Make icon color green
      icon.classList.remove("text-red-400")
      icon.classList.add("text-green-400")
    }
  
    this.updateTable()
  }
  

  toggleDropdown(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }
  

  updateTable() {
    const searchType = localStorage.getItem("searchType") || "tracks"
    const searchQuery = this.searchTarget?.value || ""

    const canonicalEnabled = this.hasFilterCanonicalTarget &&
      this.filterCanonicalTarget.classList.contains("border-green-400")

    const filters = []
    if (canonicalEnabled && (searchType === "tracks" || searchType === "albums")) {
      filters.push("is_canonical=true")
    }

    let url = `/search?search_type=${searchType}&search_query=${searchQuery}`
    if (filters.length > 0) {
      url += `&filters=${filters.join(",")}`
    }

    fetch(url, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }

  clear() {
    const input = document.querySelector(".search-input")
    if (input) input.value = ""
  }
}
