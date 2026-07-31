source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.10'

gem 'rails', '~> 8.1.3'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 6.4'

# Asset pipeline: Propshaft serves the digested assets, Tailwind compiles the
# stylesheet, and Importmap ships the JavaScript with no bundler and no
# node_modules.
gem 'propshaft'
gem 'tailwindcss-rails', '~> 4.6'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'devise'

group :development, :test do
  # Call `debugger` anywhere in the code to stop execution and get a console.
  gem 'debug', platforms: [:mri, :windows], require: 'debug/prelude'
  gem 'pry-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 3.0'
  gem 'listen', '~> 3.3'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
  # Stubs the TMDB HTTP calls so the suite never reaches the network.
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:windows, :jruby]
