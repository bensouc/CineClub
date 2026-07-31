// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Bootstrap registers its own data-api listeners on the document when imported,
// so the modals driven by data-bs-toggle keep working across Turbo navigations.
import "bootstrap"
