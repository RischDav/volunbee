import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosubmit"
export default class extends Controller {
  connect() {
    console.log("Hello Welt")
  }
}
