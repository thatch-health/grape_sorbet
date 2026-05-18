# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in sorbet_operation.gemspec
gemspec

gem "rake", "~> 13.0"

group :development, :test do
  gem "irb"
end

group :development do
  gem "sorbet", ">= 0.6"
  gem "tapioca", ">= 0.18", require: false

  gem "rubocop", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-shopify", require: false
  gem "rubocop-sorbet", require: false

  gem "bundler-audit", require: false
end

group :test do
  gem "minitest", "~> 6.0"
  gem "minitest-reporters", "~> 1.4"

  gem "simplecov", require: false

  gem "grape-entity", require: false
end
