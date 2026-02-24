import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]
  static values = { max: { type: Number, default: 500 } }

  connect() {
    this.update()
  }

  update() {
    const length = this.inputTarget.value.length
    this.countTarget.textContent = `${length}/${this.maxValue}`

    if (length > this.maxValue) {
      this.countTarget.classList.add("text-red-600")
      this.countTarget.classList.remove("text-gray-500")
    } else {
      this.countTarget.classList.remove("text-red-600")
      this.countTarget.classList.add("text-gray-500")
    }
  }
}
