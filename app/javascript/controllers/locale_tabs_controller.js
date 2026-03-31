import { Controller } from "@hotwired/stimulus"

// Language tabs for admin forms (English / Bangla)
// Usage:
//   <div data-controller="locale-tabs">
//     <button data-action="click->locale-tabs#switch" data-locale-tabs-locale-param="en">English</button>
//     <button data-action="click->locale-tabs#switch" data-locale-tabs-locale-param="bn">বাংলা</button>
//     <div data-locale-tabs-target="panel" data-locale="en">...</div>
//     <div data-locale-tabs-target="panel" data-locale="bn">...</div>
//   </div>
export default class extends Controller {
  static targets = ["panel", "tab"]

  connect() {
    this.showLocale("en")
  }

  switch({ params: { locale } }) {
    this.showLocale(locale)
  }

  showLocale(locale) {
    this.panelTargets.forEach(panel => {
      panel.hidden = panel.dataset.locale !== locale
    })

    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.localeTabsLocaleParam === locale
      tab.classList.toggle("border-blue-500", isActive)
      tab.classList.toggle("text-blue-600", isActive)
      tab.classList.toggle("border-transparent", !isActive)
      tab.classList.toggle("text-gray-500", !isActive)
    })
  }
}
