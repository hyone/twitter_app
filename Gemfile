source 'https://rubygems.org'
ruby '2.2.1'

gem 'rails', '4.2.1'
gem 'pg'

# views
gem 'bower-rails'
gem 'coffee-rails', '~> 4.1.0'
gem 'coffee-script-source', '~> 1.8.0'
gem 'i18n-js'
gem 'jbuilder', '~> 2.0'
gem 'sass-rails', '~> 5.0'
gem 'slim-rails'
gem 'therubyracer',  platforms: :ruby
gem 'turbolinks'
gem 'uglifier', '>= 1.3.0'

# auth
gem 'cancancan'
gem 'devise'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'

# others
gem 'annotate'
gem 'factory_girl_rails'
gem 'faker'
gem 'friendly_id'
gem 'kaminari'
gem 'kaminari-bootstrap'
gem 'fog', require: 'fog/aws/storage'
gem 'carrierwave'
gem 'excon', '>= 0.44.4'
gem 'mini_magick'
gem 'responders', '~> 2.0'
gem 'counter_culture', '~> 0.1.30'
gem 'ransack'
gem 'egison'

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

group :production do
  gem 'rails_12factor'
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'capybara'
  gem 'rubocop', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'foreman'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'pry-rails'
  gem 'awesome_print'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  gem 'coffee-rails-source-maps'
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'view_source_map'
end

group :test do
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
  gem 'poltergeist'
  gem 'database_rewinder'
  gem 'coveralls', require: false
  gem 'simplecov', require: false
  gem 'rake_shared_context'
end
