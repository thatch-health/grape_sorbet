# typed: strict
# frozen_string_literal: true

module Grape
  module DSL
    module Desc
      # grape evaluates config_block in the context of a dynamically created module that implements the DSL it exposes
      # at runtime. There's no good way to represent this statically, so block is just typed as T.untyped to prevent
      # Sorbet from complaining that the DSL methods don't exist.
      sig do
        params(
          description: String,
          options: T.nilable(T::Hash[Symbol, T.untyped]),
          config_block: T.nilable(T.proc.bind(T.untyped).void),
        ).void
      end
      def desc(description, options = T.unsafe(nil), &config_block); end
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

      module ClassMethods
        sig do
          params(
            new_modules: T.untyped,
            block: T.nilable(T.proc.bind(Grape::DSL::Helpers::BaseHelper).void),
          ).void
        end
        def helpers(*new_modules, &block); end
      end
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
      def error!(message, status = T.unsafe(nil), additional_headers = T.unsafe(nil), backtrace = T.unsafe(nil),
        original_exception = T.unsafe(nil))
      end

      sig { params(status: T.nilable(T.any(Integer, Symbol))).returns(Integer) }
      def status(status = nil); end

      sig { returns(Grape::Cookies) }
      def cookies; end

      sig { returns(Grape::Router::Route) }
      def route; end
    end

    module RequestResponse
      module ClassMethods
        sig { params(args: Symbol, block: T.nilable(T.proc.bind(Grape::Endpoint).params(e: Exception).void)).void }
        sig do
          type_parameters(:E)
            .params(
              args: T::Class[T.all(Exception, T.type_parameter(:E))],
              block: T.proc.bind(Grape::Endpoint).params(e: T.type_parameter(:E)).void,
            )
            .void
        end
        def rescue_from(*args, &block); end
      end
    end

    module Routing
      module ClassMethods
        # @shim: https://github.com/ruby-grape/grape/blob/v2.0.0/lib/grape/dsl/routing.rb#L148-L154
        sig do
          params(
            args: T.untyped,
            block: T.nilable(T.proc.bind(Grape::Endpoint).void),
          ).void
        end
        def delete(*args, &block); end

        # @shim: https://github.com/ruby-grape/grape/blob/v2.0.0/lib/grape/dsl/routing.rb#L148-L154
        sig do
          params(
            args: T.untyped,
            block: T.nilable(T.proc.bind(Grape::Endpoint).void),
          ).void
        end
        def get(*args, &block); end

        # @shim: https://github.com/ruby-grape/grape/blob/v2.0.0/lib/grape/dsl/routing.rb#L148-L154
        sig do
          params(
            args: T.untyped,
            block: T.nilable(T.proc.bind(Grape::Endpoint).void),
          ).void
        end
        def options(*args, &block); end

        # @shim: https://github.com/ruby-grape/grape/blob/v2.0.0/lib/grape/dsl/routing.rb#L148-L154
        sig do
          params(
            args: T.untyped,
            block: T.nilable(T.proc.bind(Grape::Endpoint).void),
          ).void
        end
        def patch(*args, &block); end

        # @shim: https://github.com/ruby-grape/grape/blob/v2.0.0/lib/grape/dsl/routing.rb#L148-L154
        sig do
          params(
            args: T.untyped,
            block: T.nilable(T.proc.bind(Grape::Endpoint).void),
          ).void
        end
        def post(*args, &block); end

        # @shim: https://github.com/ruby-grape/grape/blob/v2.0.0/lib/grape/dsl/routing.rb#L148-L154
        sig do
          params(
            args: T.untyped,
            block: T.nilable(T.proc.bind(Grape::Endpoint).void),
          ).void
        end
        def put(*args, &block); end

        sig do
          params(
            methods: T.any(Symbol, String, T::Array[String]),
            paths: T.nilable(T.any(String, T::Array[String])),
            route_options: T.nilable(T::Hash[Symbol, T.untyped]),
            block: T.nilable(T.proc.bind(Grape::Endpoint).void),
          ).void
        end
        def route(methods, paths = T.unsafe(nil), route_options = T.unsafe(nil), &block); end

        sig do
          params(
            param: Symbol,
            options: T.nilable(T::Hash[Symbol, T.untyped]),
            block: T.nilable(T.proc.bind(T.class_of(Grape::API::Instance)).void),
          ).void
        end
        def route_param(param, options = T.unsafe(nil), &block); end
      end
    end

    module Validations
      module ClassMethods
        sig { params(block: T.proc.bind(Grape::Validations::ParamsScope).void).void }
        def params(&block); end
      end
    end
  end

  class Endpoint
    sig { returns(Grape::Request) }
    def request; end
  end
end
