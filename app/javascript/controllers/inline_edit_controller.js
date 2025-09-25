import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form"]

  connect() {
    this.showDisplay()
  }

  showEdit() {
    this.displayTarget.classList.add("hidden")
    this.formTarget.classList.remove("hidden")
    this.formTarget.querySelector("textarea, input").focus()
  }

  showDisplay() {
    this.displayTarget.classList.remove("hidden")
    this.formTarget.classList.add("hidden")
  }
}