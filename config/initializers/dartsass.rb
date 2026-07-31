# Be sure to restart your server when you modify this file.

# dart-sass builds its load path from config.assets.paths, and both SCSS source
# directories are deliberately excluded from those (see config/initializers/assets.rb),
# so point the compiler at the vendored Bootstrap source explicitly.
Rails.application.config.dartsass.build_options <<
  "--load-path=#{Rails.root.join('vendor/assets/stylesheets')}"

# Bootstrap 5.3 still uses the legacy @import syntax and the old colour helpers,
# which modern dart-sass warns about on every build. Those warnings are the
# vendored library's to fix, not ours.
Rails.application.config.dartsass.build_options << "--quiet-deps"

# Our own stylesheets use @import too, and they have to: Bootstrap 5.3 relies on
# variable overrides being declared before its own @import, which the @use module
# system does not express. Revisit when we move to a Bootstrap that ships modules.
Rails.application.config.dartsass.build_options << "--silence-deprecation=import"
