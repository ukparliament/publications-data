import { Controller } from "@hotwired/stimulus";

// This is so we can tidy things up for when JS is not enabled
export default class extends Controller {
  connect() {
    this.element.classList.remove("p-form__input--with-button");
    const button = this.element.querySelector("button#search_button");
    if (button) button.hidden = true;
  }
}
