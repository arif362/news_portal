import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  close() {
    this.element.style.transition = "opacity 0.3s, max-height 0.3s"
    this.element.style.opacity = "0"
    this.element.style.maxHeight = "0"
    this.element.style.overflow = "hidden"
    setTimeout(() => this.element.remove(), 300)
  }
}
