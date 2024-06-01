# typed: strict
# frozen_string_literal: true

begin
  require "grape"
rescue LoadError
  return
end

require "active_support/core_ext/class/subclasses"

require "tapioca/dsl/helpers/grape_constants_helper"

module Tapioca
  module Dsl
    module Compilers
      # `Tapioca::Compilers::GrapeEndpoints` decorates RBI files for subclasses of `Grape::API::Instance`.
      #
      # For example, with the following `Grape::API::Instance` subclass:
      #
      # ~~~rb
      # class API < Grape::API::Instance
      #   helpers Helpers
      # end
      # ~~~
      #
      # this compiler will produce the RBI file `api.rbi` with the following content:
      # ~~~rbi
      # # api.rbi
      # # typed: true
      #
      # class API
      #   extend GeneratedRoutingMethods
      #
      #   module GeneratedRoutingMethods
      #     sig { params(args: T.untyped, blk: T.nilable(T.proc.bind(PrivateEndpoint).void)).void }
      #     def get(*args, &blk); end
      #
      #     # ...
      #
      #     sig do
      #       params(
      #         param: Symbol,
      #         options: T.nilable(T::Hash[Symbol, T.untyped]),
      #         blk: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void)
      #       ).void
      #     end
      #     def route_param(param, options = nil, &blk); end
      #   end
      #
      #   class PrivateAPIInstance < ::Grape::API::Instance
      #     extend GeneratedRoutingMethods
      #   end
      #
      #   class PrivateEndpoint < ::Grape::Endpoint
      #     include Helpers
      #   end
      # end
      # ~~~
      #
      class GrapeEndpoints < Tapioca::Dsl::Compiler
        extend T::Sig
        include Helpers::GrapeConstantsHelper

        ConstantType = type_member { { fixed: T.class_of(::Grape::API::Instance) } }

        sig { override.void }
        def decorate
          create_classes_and_includes
          create_routing_methods
        end

        class << self
          extend T::Sig

          sig { override.returns(T::Enumerable[Module]) }
          def gather_constants
            ::Grape::API::Instance.descendants
          end
        end

        HTTP_VERB_METHODS = T.let(
          [:get, :post, :put, :patch, :delete, :head, :options].freeze,
          T::Array[Symbol],
        )

        private

        sig { returns(RBI::Scope) }
        def api
          @api ||= T.let(
            root.create_path(constant),
            T.nilable(RBI::Scope),
          )
        end

        sig { returns(RBI::Scope) }
        def routing_methods_module
          @routing_methods_module ||= T.let(
            api.create_module(RoutingMethodsModuleName),
            T.nilable(RBI::Scope),
          )
        end

        sig { void }
        def create_classes_and_includes
          api.create_extend(RoutingMethodsModuleName)
          create_api_class
          create_endpoint_class
        end

        sig { void }
        def create_api_class
          superclass = "::Grape::API::Instance"

          api.create_class(APIInstanceClassName, superclass_name: superclass) do |klass|
            klass.create_extend(RoutingMethodsModuleName)
          end
        end

        sig { void }
        def create_endpoint_class
          superclass = "::Grape::Endpoint"

          helper_mods = constant.namespace_stackable(:helpers)

          if helper_mods.any? { |mod| mod.name.nil? }
            raise "Cannot compile Grape API with anonymous helpers"
          end

          api.create_class(EndpointClassName, superclass_name: superclass) do |klass|
            helper_mods.each do |mod|
              klass.create_include(mod.name)
            end
          end
        end

        sig { void }
        def create_routing_methods
          HTTP_VERB_METHODS.each do |verb|
            routing_methods_module.create_method(
              verb.to_s,
              parameters: [
                create_rest_param("args", type: "T.untyped"),
                create_block_param("blk", type: "T.nilable(T.proc.bind(#{EndpointClassName}).void)"),
              ],
              return_type: "void",
            )
          end

          routing_methods_module.create_method(
            "route_param",
            parameters: [
              create_param("param", type: "Symbol"),
              create_opt_param("options", type: "T.nilable(T::Hash[Symbol, T.untyped])", default: "nil"),
              create_block_param("blk", type: "T.nilable(T.proc.bind(T.class_of(#{APIInstanceClassName})).void)"),
            ],
            return_type: "void",
          )
        end
      end
    end
  end
end
