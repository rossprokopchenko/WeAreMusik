
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search"]

  change(event) {
    // Handle dropdown change
    // console.log("Search type changed to:", event.target.value)
    this.updateTable()
  }

  search(event) {
    // Handle search input
    
    clearTimeout(this.constructor.timeout)
    this.constructor.timeout = setTimeout(() => {
      this.updateTable()
      // this.element.requestSubmit()
    }, 200)
  }

  updateTable() {
    const searchType = this.element.querySelector('#search_type_select').value
    // console.log("Search target value:", this.searchTarget);
    const searchQuery = this.searchTarget.value

    const url = `/search?search_type=${searchType}&search_query=${searchQuery}`

    fetch(url, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })
    .then(response => response.text())
    .then(html => Turbo.renderStreamMessage(html))
  }

  // submit(event) {
  //   clearTimeout(this.constructor.timeout)
  //   this.constructor.timeout = setTimeout(() => {
  //     this.element.requestSubmit()
  //   }, 200)
  // }

  clear() {
    const input = document.querySelector(".search-input")
    if (input) input.value = ""
  }
}