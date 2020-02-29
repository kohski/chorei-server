# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'devise'
gem 'devise_token_auth'
gem 'dotenv-rails'
gem 'fast_jsonapi'
gem 'jbuilder', '~> 2.5'
gem 'mini_racer', platforms: :ruby
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.12'
gem 'rack-cors'
gem 'rails', '~> 5.2.3'
gem 'rspec-core'
gem 'rswag'
gem 'unicorn'

group :development, :test do
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capistrano', '3.6.0'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano3-unicorn'
  gem 'codecov', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'rubocop', require: false
  gem 'simplecov', require: false
  gem 'spring-commands-rspec'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pre-commit', require: false
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
