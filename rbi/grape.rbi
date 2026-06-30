# typed: strict
# frozen_string_literal: true

module Grape
  module DSL
    module Desc
      # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/desc.rb#L8-L68
      sig do
        params(
          description: String,
          legacy_options: T.untyped,
          options: T.untyped,
          config_block: T.nilable(T.proc.bind(Grape::Util::ApiDescription).void),
        ).void
      end
      def desc(description, *legacy_options, **options, &config_block); end
    end

    module Helpers
      module BaseHelper
        # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/helpers.rb#L103-L106
        sig do
          params(
            name: Symbol,
            block: T.proc.bind(Grape::Validations::ParamsScope).params(options: T::Hash[Symbol, T.untyped]).void,
          ).void
        end
        def params(name, &block); end
      end

      # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/helpers.rb#L6-L35
      sig do
        params(
          new_modules: T.untyped,
          block: T.nilable(T.proc.bind(Grape::DSL::Helpers::BaseHelper).void),
        ).void
      end
      def helpers(*new_modules, &block); end
    end

    module InsideRoute
      # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/inside_route.rb#L21-L35
      sig do
        params(
          message: T.any(String, T::Hash[Symbol, T.untyped]),
          status: T.nilable(T.any(Integer, Symbol)),
          additional_headers: T.nilable(T::Hash[String, String]),
          backtrace: T.nilable(T::Array[String]),
          original_exception: T.nilable(Exception),
        ).returns(T.noreturn)
      end
      def error!(message, status = nil, additional_headers = nil, backtrace = nil, original_exception = nil); end

      # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/inside_route.rb#L59-L71
      sig { params(status: T.nilable(T.any(Integer, Symbol))).returns(Integer) }
      def status(status = nil); end

      # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/inside_route.rb#L158-L168
      sig { returns(Grape::Router::Route) }
      def route; end
    end

    module RequestResponse
      # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/request_response.rb#L85-L128
      sig do
        params(
          args: Symbol,
          # Sorbet doesn't support keyword arguments in overloaded functions :(
          # with: T.untyped,
          # rescue_subclasses: T::Boolean,
          # backtrace: T::Boolean,
          # original_exception: T::Boolean,
          block: T.proc.bind(Grape::Endpoint).params(e: Exception).void,
        )
          .void
      end
      sig do
        type_parameters(:E)
          .params(
            args: T::Class[T.all(Exception, T.type_parameter(:E))],
            with: T.untyped,
            rescue_subclasses: T::Boolean,
            backtrace: T::Boolean,
            original_exception: T::Boolean,
            block: T.proc.bind(Grape::Endpoint).params(e: T.type_parameter(:E)).void,
          )
          .void
      end
      def rescue_from(*args, with: nil, rescue_subclasses: true, backtrace: false, original_exception: false, &block); end
    end

    module Routing
      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/routing.rb#L203-L207
      sig do
        params(
          path: String,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def delete(path = '/', **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/routing.rb#L203-L207
      sig do
        params(
          path: String,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def get(path = '/', **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/routing.rb#L203-L207
      sig do
        params(
          path: String,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def options(path = '/', **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/routing.rb#L203-L207
      sig do
        params(
          path: String,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def patch(path = '/', **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/routing.rb#L203-L207
      sig do
        params(
          path: String,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def post(path = '/', **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/routing.rb#L203-L207
      sig do
        params(
          path: String,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def put(path = '/', **options, &block); end

      # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/routing.rb#L169-L201
      sig do
        params(
          methods: T.any(Symbol, String, T::Array[String]),
          paths: T.nilable(T.any(String, T::Array[String])),
          route_options: T::Hash[Symbol, T.untyped],
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def route(methods, paths = ['/'], route_options = {}, &block); end

      # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/routing.rb#L241-L254
      sig do
        params(
          param: Symbol,
          requirements: T.nilable(T::Hash[Symbol, T.untyped]),
          type: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def route_param(param, requirements: nil, type: nil, **options, &block); end
    end

    module Validations
      # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/dsl/validations.rb#L6-L11
      sig { params(block: T.proc.bind(Grape::Validations::ParamsScope).void).void }
      def params(&block); end
    end
  end

  class Endpoint
    # https://github.com/ruby-grape/grape/blob/v3.3.1/lib/grape/endpoint.rb#L14
    sig { returns(Grape::Request) }
    def request; end
  end
end
