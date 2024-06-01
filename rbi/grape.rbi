# typed: strict
# frozen_string_literal: true

module Grape
  module DSL::Callbacks::ClassMethods
    sig { params(block: T.proc.bind(Grape::Endpoint).void).void }
    def before(&block); end
  end

  module DSL::Desc
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

  module DSL::RequestResponse::ClassMethods
    sig { params(args: T.untyped, block: T.proc.bind(Grape::Endpoint).void).void }
    def rescue_from(*args, &block); end
  end

  module DSL::Routing::ClassMethods
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

  module DSL::Validations::ClassMethods
    sig { params(block: T.proc.bind(Grape::Validations::ParamsScope).void).void }
    def params(&block); end
  end
end
