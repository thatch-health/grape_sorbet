# grape_sorbet

[![Build Status](https://github.com/thatch-health/grape_sorbet/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/thatch-health/grape_sorbet/actions?query=branch%3Amain)
[![Gem Version ](https://img.shields.io/gem/v/grape_sorbet.svg?style=flat)](https://rubygems.org/gems/grape_sorbet)

grape_sorbet is a gem that provides hand written signatures and a Tapioca DSL compiler that makes it more pleasant to use the [Grape](https://github.com/ruby-grape/grape) API framework in Ruby projects that use the [Sorbet](https://sorbet.org/) typechecker.


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add grape_sorbet

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install specific_install
    $ gem specific_install https://github.com/thatch-health/grape_sorbet.git

After installing the gem, make sure to run `bundle exec tapioca gem grape_sorbet` in your project to import the hand written signatures.

## Usage

Starting with the following example from grape's documentation:

```ruby
module Twitter
  class API < Grape::API
    version 'v1', using: :header, vendor: 'twitter'
    format :json
    prefix :api

    helpers do
      def current_user
        @current_user ||= User.authorize!(env)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

    resource :statuses do
      desc 'Return a personal timeline.'
      get :home_timeline do
        authenticate!
        current_user.statuses.limit(20)
      end
    end
  end
end
```

First, you'll need to make the following changes:

* derive from `Grape::API::Instance` rather than `Grape::API`
* change the `helpers` call to replace the block parameter with a named module

You'll also need to use `T.bind(self, T.all(Grape::Endpoint, <HelpersModuleName>))` in helper methods that use methods provided by Grape (e.g. `env` in `current_user` or `error!` in `authenticate!`) or other methods from the same helper module (e.g. `current_user` in `authenticate!`).

With the changes:

```ruby
module Twitter
  class API < Grape::API::Instance
    version 'v1', using: :header, vendor: 'twitter'
    format :json
    prefix :api

    module Helpers
      def current_user
        T.bind(self, T.all(Grape::Endpoint, Helpers))
        @current_user ||= User.authorize!(env)
      end

      def authenticate!
        T.bind(self, T.all(Grape::Endpoint, Helpers))
        error!('401 Unauthorized', 401) unless current_user
      end
    end
    helpers Helpers

    resource :statuses do
      desc 'Return a personal timeline.'
      get :home_timeline do
        authenticate!
        current_user.statuses.limit(20)
      end
    end
  end
end
```

At this point Sorbet is still reporting errors in the `get :home_timeline` block, because it doesn't know that these blocks are executed in a context where the `Helpers` module methods will be available. The Tapioca compiler provided by this gem will fix that. Run `bundle exec tapioca dsl`. This should generate a `sorbet/rbi/dsl/twitter/api.rbi` file (assuming the source file is in `lib/twitter/api.rb`).

After this, Sorbet should no longer report any errors.

## Limitations and known issues

### Subclassing from `Grape::API::Instance` instead of `Grape::API`

Grape overrides `Grape::API.new` and uses the `inherited` hook so that subclasses of `Grape::API` are really subclasses of `Grape::API::Instance`.

This might be fixable in a future update of grape_sorbet, but is very low priority.

### Not being able to call `helpers` with block arguments

Possibly fixable in a future update.

### Having to use `T.bind(self, T.any(Grape::Endpoint, <HelpersModuleName>))` in helper methods

Possibly fixable in a future update.

### Having to use `T.bind(self, T.any(Grape::Endpoint, <HelpersModuleName>))` in `before` and `after` callback blocks

The compiler already generates proper signatures for callback methods so `T.bind` should not be needed (and is in fact unneeded for the other callback methods, `before_validation`, `after_validation` and `finally`). The reason it doesn't work for `before` and `after` is because of a [bug](https://github.com/sorbet/sorbet/issues/7950) in Sorbet itself.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thatch-health/grape_sorbet. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/thatch-health/grape_sorbet/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TestGem project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/thatch-health/grape_sorbet/blob/main/CODE_OF_CONDUCT.md).
