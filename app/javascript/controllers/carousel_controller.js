import { Controller } from "@hotwired/stimulus"

// Verbindet sich mit data-controller="carousel"
export default class extends Controller {
  static targets = ["slide"]

  initialize() {
    this.index = 0
    this.showCurrentSlide()
  }

  next() {
    this.index++
    if (this.index >= this.slideTargets.length) {
      this.index = 0
    }
    this.showCurrentSlide()
  }

  previous() {
    this.index--
    if (this.index < 0) {
      this.index = this.slideTargets.length - 1
    }
    this.showCurrentSlide()
  }

  showCurrentSlide() {
    this.slideTargets.forEach((element, index) => {
      element.classList.toggle("hidden", index !== this.index)
    })
  }
}