# typed: strict
# frozen_string_literal: true

module Grape
  module DSL
    module Desc
      sig do
        params(
          description: String,
          options: T::Hash[Symbol, T.untyped],
          config_block: T.nilable(T.proc.bind(Grape::Util::ApiDescription).void),
        ).void
      end
      def desc(description, options = {}, &config_block); end
    end

    module Helpers
      module BaseHelper
        sig do
          params(
            name: Symbol,
            block: T.proc.bind(Grape::Validations::ParamsScope).params(options: T::Hash[Symbol, T.untyped]).void,
          ).void
        end
        def params(name, &block); end
      end

      sig do
        params(
          new_modules: T.untyped,
          block: T.nilable(T.proc.bind(Grape::DSL::Helpers::BaseHelper).void),
        ).void
      end
      def helpers(*new_modules, &block); end
    end

    module InsideRoute
      sig do
        params(
          message: T.any(String, T::Hash[Symbol, T.untyped]),
          status: T.nilable(T.any(Integer, Symbol)),
          additional_headers: T.nilable(T::Hash[String, String]),
          backtrace: T.nilable(T::Array[String]),
          original_exception: T.nilable(Exception),
        ).returns(T.noreturn)
      end
      def error!(message, status = nil, additional_headers = nil, backtrace = nil, original_exception = nil)
      end

      sig { params(status: T.nilable(T.any(Integer, Symbol))).returns(Integer) }
      def status(status = nil); end

      sig { returns(Grape::Router::Route) }
      def route; end
    end

    module RequestResponse
      sig do
        params(
          args: Symbol,
          # Sorbet doesn't support keyword arguments in overloaded functions :(
          # options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).params(e: Exception).void),
        ).void
      end
      sig do
        type_parameters(:E)
          .params(
            args: T::Class[T.all(Exception, T.type_parameter(:E))],
            options: T.untyped,
            block: T.proc.bind(Grape::Endpoint).params(e: T.type_parameter(:E)).void,
          )
          .void
      end
      def rescue_from(*args, **options, &block); end
    end

    module Routing
      # @shim: https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L182-L187
      sig do
        params(
          args: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def delete(*args, **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L182-L187
      sig do
        params(
          args: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def get(*args, **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L182-L187
      sig do
        params(
          args: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def options(*args, **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L182-L187
      sig do
        params(
          args: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def patch(*args, **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L182-L187
      sig do
        params(
          args: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def post(*args, **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L182-L187
      sig do
        params(
          args: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def put(*args, **options, &block); end

      sig do
        params(
          methods: T.any(Symbol, String, T::Array[String]),
          paths: T.nilable(T.any(String, T::Array[String])),
          route_options: T::Hash[Symbol, T.untyped],
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def route(methods, paths = ["/"], route_options = {}, &block); end

      sig do
        params(
          param: Symbol,
          requirements: T.nilable(T::Hash[Symbol, T.untyped]),
          type: T.untyped,
          _arg3: T.untyped,
          _arg4: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def route_param(param, requirements: nil, type: nil, **_arg3, &_arg4); end
    end

    module Validations
      sig { params(block: T.proc.bind(Grape::Validations::ParamsScope).void).void }
      def params(&block); end
    end
  end

  class Endpoint
    sig { returns(Grape::Request) }
    def request; end
  end
end
