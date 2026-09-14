import { Controller } from "@hotwired/stimulus"

// Replaces the clipboard.js init that was duplicated inline in index, show
// and trend, and leaked listeners on every Turbolinks navigation.
export default class extends Controller {
  static values = { text: String }

  async copy(event) {
    event.preventDefault()

    try {
      await navigator.clipboard.writeText(this.textValue)
      this.flash()
    } catch {
      // Clipboard API needs a secure context; fail quietly like the original.
    }
  }

  flash() {
    this.element.classList.add("copied")
    setTimeout(() => this.element.classList.remove("copied"), 600)
  }
}
