import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track"]
  static values = { speed: { type: Number, default: 50 } }

  connect() {
    this.paused = false
    this.position = 0
    this.setupTrack()
    this.startAnimation()
  }

  disconnect() {
    this.stopAnimation()
  }

  setupTrack() {
    // Duplicate content for seamless loop
    const track = this.trackTarget
    track.innerHTML += track.innerHTML
  }

  startAnimation() {
    this.animationId = requestAnimationFrame((ts) => this.tick(ts))
  }

  stopAnimation() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
      this.animationId = null
    }
  }

  tick(timestamp) {
    if (!this.lastTimestamp) this.lastTimestamp = timestamp
    const delta = timestamp - this.lastTimestamp
    this.lastTimestamp = timestamp

    if (!this.paused) {
      this.position -= (this.speedValue * delta) / 1000
      const track = this.trackTarget
      const halfWidth = track.scrollWidth / 2

      // Reset when first half has scrolled away
      if (Math.abs(this.position) >= halfWidth) {
        this.position += halfWidth
      }

      track.style.transform = `translateX(${this.position}px)`
    }

    this.animationId = requestAnimationFrame((ts) => this.tick(ts))
  }

  pause() {
    this.paused = true
  }

  resume() {
    this.paused = false
    this.lastTimestamp = null
  }
}
