# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Both of these directories are dart-sass *inputs*, not servable assets: the SCSS
# under app/assets/stylesheets is compiled into app/assets/builds/application.css
# (which Propshaft does serve), and vendor/assets/stylesheets only holds
# Bootstrap's SCSS source so `@import "bootstrap/scss/bootstrap"` resolves.
Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")
Rails.application.config.assets.excluded_paths << Rails.root.join("vendor/assets/stylesheets")
