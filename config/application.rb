require_relative "boot"

require "rails"

# Only the frameworks this app actually uses. Action Cable, Active Storage,
# Action Mailbox and Action Text are all deliberately absent: nothing declares a
# channel, an attachment or a rich text field. Action Mailer and Active Job stay
# for Devise's recoverable/rememberable modules.
%w[
  active_record/railtie
  active_job/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  rails/test_unit/railtie
].each { |railtie| require railtie }

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Cineclub
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    config.autoload_lib(ignore: %w[assets tasks templates])

    # The app is French-facing: Devise flashes and validation messages should be
    # too. Dates already pass locale: :fr explicitly in the views.
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [:fr, :en]

    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
  end
end
