import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { id: String, delay: { type: Number, default: 3000 } }

  connect() {
    const key = `ad_popup_seen_${this.idValue}`
    if (sessionStorage.getItem(key)) {
      this.element.remove()
      return
    }

    this.timer = setTimeout(() => {
      this.element.classList.remove("hidden")
      sessionStorage.setItem(key, "1")
    }, this.delayValue)
  }

  disconnect() {
    if (this.timer) clearTimeout(this.timer)
  }

  close() {
    this.element.classList.add("hidden")
    setTimeout(() => this.element.remove(), 300)
  }
}
