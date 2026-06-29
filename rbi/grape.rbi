# typed: strict
# frozen_string_literal: true

module Grape
  module DSL
    module Desc
      sig do
        params(
          description: String,
          legacy_options: T::Hash[Symbol, T.untyped],
          options: T::Hash[Symbol, T.untyped],
          config_block: T.nilable(T.proc.bind(Grape::Util::ApiDescription).void),
        ).void
      end
      def desc(description, *legacy_options, **options, &config_block); end
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
      # Grape 3.3.0 declares explicit keyword arguments, and Sorbet doesn't
      # support keyword arguments in overloaded functions
      sig do
        params(
          args: T.untyped,
          with: T.untyped,
          rescue_subclasses: T.untyped,
          backtrace: T.untyped,
          original_exception: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).params(e: Exception).void),
        ).void
      end
      def rescue_from(*args, with: T.unsafe(nil), rescue_subclasses: T.unsafe(nil), backtrace: T.unsafe(nil), original_exception: T.unsafe(nil), &block); end
    end

    module Routing
      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.0/lib/grape/dsl/routing.rb#L204
      sig do
        params(
          path: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def delete(path = T.unsafe(nil), **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.0/lib/grape/dsl/routing.rb#L204
      sig do
        params(
          path: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def get(path = T.unsafe(nil), **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.0/lib/grape/dsl/routing.rb#L204
      sig do
        params(
          path: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def options(path = T.unsafe(nil), **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.0/lib/grape/dsl/routing.rb#L204
      sig do
        params(
          path: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def patch(path = T.unsafe(nil), **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.0/lib/grape/dsl/routing.rb#L204
      sig do
        params(
          path: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def post(path = T.unsafe(nil), **options, &block); end

      # @shim: https://github.com/ruby-grape/grape/blob/v3.3.0/lib/grape/dsl/routing.rb#L204
      sig do
        params(
          path: T.untyped,
          options: T.untyped,
          block: T.nilable(T.proc.bind(Grape::Endpoint).void),
        ).void
      end
      def put(path = T.unsafe(nil), **options, &block); end

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
