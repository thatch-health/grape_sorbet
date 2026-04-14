# typed: strict
# frozen_string_literal: true

require "spec_helper"

module Tapioca
  module Dsl
    module Compilers
      class GrapeEndpointsSpec < ::DslSpec
        describe "Tapioca::Dsl::Compilers::GrapeEndpoints" do
          before(:all) do
            require "grape"
          end

          describe "initialize" do
            it "gathers no constants if there are no Grape::API::Instance subclasses" do
              assert_empty(gathered_constants)
            end

            it "gathers constants for Grape::API::Instance subclasses" do
              add_ruby_file("api.rb", <<~RUBY)
                class TwitterAPI < Grape::API::Instance
                end

                class NotAnAPI
                end
              RUBY

              assert_equal(["TwitterAPI"], gathered_constants)
            end
          end

          describe "decorate" do
            it "generates proper classes and modules" do
              add_ruby_file("twitter_api.rb", <<~RUBY)
                class TwitterAPI < Grape::API::Instance
                  version 'v1', using: :header, vendor: 'twitter'
                  format :json
                  prefix :api

                  module Helpers
                    def current_user
                      @current_user ||= User.authorize!(env)
                    end

                    def authenticate!
                      error!('401 Unauthorized', 401) unless current_user
                    end
                  end
                  helpers Helpers

                  resource :statuses do
                    desc 'Return a public timeline.'
                    get :public_timeline do
                      Status.limit(20)
                    end
                  end
                end
              RUBY

              expected = template(<<~RUBY)
                # typed: strong

                class TwitterAPI
                  extend GeneratedCallbacksMethods
                  extend GeneratedRequestResponseMethods
                  extend GeneratedRoutingMethods

                  module GeneratedCallbacksMethods
                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def after(&block); end

                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def after_validation(&block); end

                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def before(&block); end

                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def before_validation(&block); end

                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def finally(&block); end
                  end

                  module GeneratedRequestResponseMethods
                    sig { params(args: Symbol, block: T.nilable(T.proc.bind(PrivateEndpoint).params(e: Exception).void)).void }
                    sig { type_parameters(:E).params(args: T::Class[T.all(::Exception, T.type_parameter(:E))], options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).params(e: T.type_parameter(:E)).void)).void }
                    def rescue_from(*args, **options, &block); end
                  end

                  module GeneratedRoutingMethods
                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def delete(*args, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def get(*args, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def group(space = nil, requirements: nil, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def head(*args, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def namespace(space = nil, requirements: nil, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def options(*args, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def patch(*args, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def post(*args, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def put(*args, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resource(space = nil, requirements: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resources(space = nil, requirements: nil, **options, &block); end

                    sig { params(methods: T.untyped, paths: T.untyped, route_options: T::Hash[Symbol, T.untyped], block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def route(methods, paths = ['/'], route_options = {}, &block); end

                    sig { params(param: Symbol, requirements: T.untyped, type: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def route_param(param, requirements: nil, type: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def segment(space = nil, requirements: nil, **options, &block); end
                  end

                  class PrivateAPIInstance < ::Grape::API::Instance
                    extend GeneratedCallbacksMethods
                    extend GeneratedRequestResponseMethods
                    extend GeneratedRoutingMethods
                  end

                  class PrivateEndpoint < ::Grape::Endpoint
                    include TwitterAPI::Helpers
                  end
                end
              RUBY

              assert_equal(expected, rbi_for(:TwitterAPI))
            end

            it "ignores anonymous helpers" do
              add_ruby_file("twitter_api.rb", <<~RUBY)
                class TwitterAPI < Grape::API::Instance
                  version 'v1', using: :header, vendor: 'twitter'
                  format :json
                  prefix :api

                  helpers do
                    params :pagination do
                      optional :page, type: Integer
                      optional :per_page, type: Integer
                    end
                  end

                  resource :statuses do
                    desc 'Return a public timeline.'
                    get :public_timeline do
                      Status.limit(20)
                    end
                  end
                end
              RUBY

              expected = template(<<~RUBY)
                # typed: strong

                class TwitterAPI
                  extend GeneratedCallbacksMethods
                  extend GeneratedRequestResponseMethods
                  extend GeneratedRoutingMethods

                  module GeneratedCallbacksMethods
                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def after(&block); end

                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def after_validation(&block); end

                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def before(&block); end

                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def before_validation(&block); end

                    sig { params(block: T.proc.bind(PrivateEndpoint).void).void }
                    def finally(&block); end
                  end

                  module GeneratedRequestResponseMethods
                    sig { params(args: Symbol, block: T.nilable(T.proc.bind(PrivateEndpoint).params(e: Exception).void)).void }
                    sig { type_parameters(:E).params(args: T::Class[T.all(::Exception, T.type_parameter(:E))], options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).params(e: T.type_parameter(:E)).void)).void }
                    def rescue_from(*args, **options, &block); end
                  end

                  module GeneratedRoutingMethods
                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def delete(*args, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def get(*args, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def group(space = nil, requirements: nil, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def head(*args, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def namespace(space = nil, requirements: nil, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def options(*args, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def patch(*args, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def post(*args, **options, &block); end

                    sig { params(args: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def put(*args, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resource(space = nil, requirements: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resources(space = nil, requirements: nil, **options, &block); end

                    sig { params(methods: T.untyped, paths: T.untyped, route_options: T::Hash[Symbol, T.untyped], block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def route(methods, paths = ['/'], route_options = {}, &block); end

                    sig { params(param: Symbol, requirements: T.untyped, type: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def route_param(param, requirements: nil, type: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def segment(space = nil, requirements: nil, **options, &block); end
                  end

                  class PrivateAPIInstance < ::Grape::API::Instance
                    extend GeneratedCallbacksMethods
                    extend GeneratedRequestResponseMethods
                    extend GeneratedRoutingMethods
                  end

                  class PrivateEndpoint < ::Grape::Endpoint; end
                end
              RUBY

              assert_equal(expected, rbi_for(:TwitterAPI))
            end
          end
        end
      end
    end
  end
end
