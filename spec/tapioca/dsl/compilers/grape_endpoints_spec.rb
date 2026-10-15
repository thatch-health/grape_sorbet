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
              add_ruby_file("base_api.rb", <<~RUBY)
                class BaseAPI < Grape::API::Instance
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
                end
              RUBY

              add_ruby_file("twitter_api.rb", <<~RUBY)
                require_relative "./base_api"

                class TwitterAPI < BaseAPI
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
                    sig { type_parameters(:E).params(args: T::Class[T.all(::Exception, T.type_parameter(:E))], with: T.untyped, rescue_subclasses: T::Boolean, backtrace: T::Boolean, original_exception: T::Boolean, block: T.nilable(T.proc.bind(PrivateEndpoint).params(e: T.type_parameter(:E)).void)).void }
                    def rescue_from(*args, with: nil, rescue_subclasses: true, backtrace: false, original_exception: false, &block); end
                  end

                  module GeneratedRoutingMethods
                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def delete(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def get(path = '/', **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def group(space = nil, requirements: nil, **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def head(path = '/', **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def namespace(space = nil, requirements: nil, **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def options(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def patch(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def post(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def put(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def query(path = '/', **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resource(space = nil, requirements: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resources(space = nil, requirements: nil, **options, &block); end

                    sig { params(methods: T.any(Symbol, String, T::Array[String]), paths: T.nilable(T.any(String, T::Array[String])), requirements: T.nilable(T::Hash[Symbol, T.untyped]), anchor: T::Boolean, route_options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def route(methods, paths = ['/'], requirements: nil, anchor: true, **route_options, &block); end

                    sig { params(param: Symbol, requirements: T.untyped, type: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def route_param(param, requirements: nil, type: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def segment(space = nil, requirements: nil, **options, &block); end
                  end

                  class PrivateAPIInstance < BaseAPI
                    extend GeneratedCallbacksMethods
                    extend GeneratedRequestResponseMethods
                    extend GeneratedRoutingMethods
                  end

                  class PrivateEndpoint < ::Grape::Endpoint
                    include BaseAPI::Helpers
                  end
                end
              RUBY

              assert_equal(expected, rbi_for(:TwitterAPI))
            end

            it "copies the methods of helpers blocks to the endpoint" do
              add_ruby_file("twitter_api.rb", <<~RUBY)
                class TwitterAPI < Grape::API::Instance
                  helpers do
                    def current_user
                      @current_user ||= User.authorize!(env)
                    end

                    def authenticate!
                      error!('401 Unauthorized', 401) unless current_user
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
                  include ::Grape::DSL::Settings
                  include ::Grape::DSL::Headers
                  include ::Grape::DSL::InsideRoute

                  sig { returns(T.untyped) }
                  def api; end

                  sig { returns(T.untyped) }
                  def cookies; end

                  sig { returns(T.untyped) }
                  def env; end

                  sig { returns(T.untyped) }
                  def logger; end

                  sig { returns(T.untyped) }
                  def options; end

                  sig { returns(T.untyped) }
                  def params; end

                  sig { returns(::Grape::Request) }
                  def request; end

                  sig { returns(T.untyped) }
                  def response_cookies; end

                  sig { returns(T.untyped) }
                  def source; end

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
                    sig { type_parameters(:E).params(args: T::Class[T.all(::Exception, T.type_parameter(:E))], with: T.untyped, rescue_subclasses: T::Boolean, backtrace: T::Boolean, original_exception: T::Boolean, block: T.nilable(T.proc.bind(PrivateEndpoint).params(e: T.type_parameter(:E)).void)).void }
                    def rescue_from(*args, with: nil, rescue_subclasses: true, backtrace: false, original_exception: false, &block); end
                  end

                  module GeneratedRoutingMethods
                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def delete(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def get(path = '/', **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def group(space = nil, requirements: nil, **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def head(path = '/', **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def namespace(space = nil, requirements: nil, **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def options(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def patch(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def post(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def put(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def query(path = '/', **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resource(space = nil, requirements: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resources(space = nil, requirements: nil, **options, &block); end

                    sig { params(methods: T.any(Symbol, String, T::Array[String]), paths: T.nilable(T.any(String, T::Array[String])), requirements: T.nilable(T::Hash[Symbol, T.untyped]), anchor: T::Boolean, route_options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def route(methods, paths = ['/'], requirements: nil, anchor: true, **route_options, &block); end

                    sig { params(param: Symbol, requirements: T.untyped, type: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def route_param(param, requirements: nil, type: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def segment(space = nil, requirements: nil, **options, &block); end
                  end

                  class PrivateAPIInstance < Grape::API::Instance
                    extend GeneratedCallbacksMethods
                    extend GeneratedRequestResponseMethods
                    extend GeneratedRoutingMethods
                  end

                  class PrivateEndpoint < ::Grape::Endpoint
                    sig { returns(T.untyped) }
                    def authenticate!; end

                    sig { returns(T.untyped) }
                    def current_user; end
                  end
                end
              RUBY

              assert_equal(expected, rbi_for(:TwitterAPI))
            end

            it "copies the signatures of helpers block methods" do
              add_ruby_file("twitter_api.rb", <<~RUBY)
                class TwitterAPI < Grape::API::Instance
                  helpers do
                    extend T::Sig

                    sig { params(id: Integer, options: T.untyped).returns(String) }
                    def find(id, **options) = id.to_s
                  end
                end
              RUBY

              assert_includes(rbi_for(:TwitterAPI), <<~RBI.indent(2))
                class PrivateEndpoint < ::Grape::Endpoint
                  sig { params(id: ::Integer, options: T.untyped).returns(::String) }
                  def find(id, **options); end
                end
              RBI
            end

            it "keeps helpers block methods private" do
              add_ruby_file("twitter_api.rb", <<~RUBY)
                class TwitterAPI < Grape::API::Instance
                  helpers do
                    def current_user; end

                    private

                    def token(header, prefix = "Bearer"); end
                  end
                end
              RUBY

              assert_includes(rbi_for(:TwitterAPI), <<~RBI.indent(2))
                class PrivateEndpoint < ::Grape::Endpoint
                  sig { returns(T.untyped) }
                  def current_user; end

                  private

                  sig { params(header: T.untyped, prefix: T.untyped).returns(T.untyped) }
                  def token(header, prefix = T.unsafe(nil)); end
                end
              RBI
            end

            it "supports named helpers and helpers blocks together" do
              add_ruby_file("twitter_api.rb", <<~RUBY)
                class TwitterAPI < Grape::API::Instance
                  module Helpers
                    def current_user; end
                  end
                  helpers Helpers

                  helpers do
                    def authenticate!
                      error!('401 Unauthorized', 401) unless current_user
                    end
                  end
                end
              RUBY

              rbi = rbi_for(:TwitterAPI)

              assert_includes(rbi, <<~RBI)
                class TwitterAPI
                  extend GeneratedCallbacksMethods
                  extend GeneratedRequestResponseMethods
                  extend GeneratedRoutingMethods
                  include ::Grape::DSL::Settings
                  include ::Grape::DSL::Headers
                  include ::Grape::DSL::InsideRoute
                  include TwitterAPI::Helpers
              RBI
              assert_includes(rbi, <<~RBI.indent(2))
                class PrivateEndpoint < ::Grape::Endpoint
                  include TwitterAPI::Helpers

                  sig { returns(T.untyped) }
                  def authenticate!; end
                end
              RBI
            end

            it "does not add endpoint readers that a helpers block defines" do
              add_ruby_file("twitter_api.rb", <<~RUBY)
                class TwitterAPI < Grape::API::Instance
                  helpers do
                    def params; end
                  end
                end
              RUBY

              rbi = rbi_for(:TwitterAPI)

              assert_includes(rbi, "  def env; end\n")
              assert_equal(1, rbi.scan("def params; end").size)
            end

            it "copies the methods of helpers blocks from the superclass" do
              add_ruby_file("base_api.rb", <<~RUBY)
                class BaseAPI < Grape::API::Instance
                  helpers do
                    def current_user; end
                  end
                end
              RUBY

              add_ruby_file("twitter_api.rb", <<~RUBY)
                require_relative "./base_api"

                class TwitterAPI < BaseAPI
                end
              RUBY

              assert_includes(rbi_for(:TwitterAPI), <<~RBI.indent(2))
                class PrivateEndpoint < ::Grape::Endpoint
                  sig { returns(T.untyped) }
                  def current_user; end
                end
              RBI
            end

            it "ignores helpers blocks without methods" do
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
                    sig { type_parameters(:E).params(args: T::Class[T.all(::Exception, T.type_parameter(:E))], with: T.untyped, rescue_subclasses: T::Boolean, backtrace: T::Boolean, original_exception: T::Boolean, block: T.nilable(T.proc.bind(PrivateEndpoint).params(e: T.type_parameter(:E)).void)).void }
                    def rescue_from(*args, with: nil, rescue_subclasses: true, backtrace: false, original_exception: false, &block); end
                  end

                  module GeneratedRoutingMethods
                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def delete(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def get(path = '/', **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def group(space = nil, requirements: nil, **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def head(path = '/', **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def namespace(space = nil, requirements: nil, **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def options(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def patch(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def post(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def put(path = '/', **options, &block); end

                    sig { params(path: String, options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def query(path = '/', **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resource(space = nil, requirements: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def resources(space = nil, requirements: nil, **options, &block); end

                    sig { params(methods: T.any(Symbol, String, T::Array[String]), paths: T.nilable(T.any(String, T::Array[String])), requirements: T.nilable(T::Hash[Symbol, T.untyped]), anchor: T::Boolean, route_options: T.untyped, block: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
                    def route(methods, paths = ['/'], requirements: nil, anchor: true, **route_options, &block); end

                    sig { params(param: Symbol, requirements: T.untyped, type: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def route_param(param, requirements: nil, type: nil, **options, &block); end

                    sig { params(space: T.untyped, requirements: T.untyped, options: T.untyped, block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)).void }
                    def segment(space = nil, requirements: nil, **options, &block); end
                  end

                  class PrivateAPIInstance < Grape::API::Instance
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
