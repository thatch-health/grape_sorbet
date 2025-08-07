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

          create_callbacks_methods
          create_request_response_methods
          create_routing_methods
        end

        class << self
          extend T::Sig

          sig { override.returns(T::Enumerable[Module]) }
          def gather_constants
            ::Grape::API::Instance.descendants
          end
        end

        # https://github.com/ruby-grape/grape/blob/v2.4.0/lib/grape/dsl/callbacks.rb#L23-L66
        CALLBACKS_METHODS = T.let(
          [:before, :before_validation, :after_validation, :after, :finally].freeze,
          T::Array[Symbol],
        )

        # https://github.com/ruby-grape/grape/blob/master/lib/grape.rb#L62-L70
        HTTP_VERB_METHODS = T.let(
          [:get, :post, :put, :patch, :delete, :head, :options].freeze,
          T::Array[Symbol],
        )

        # https://github.com/ruby-grape/grape/blob/v2.4.0/lib/grape/dsl/routing.rb#L173-L198
        NAMESPACE_METHODS = T.let(
          [:namespace, :group, :resource, :resources, :segment].freeze,
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
        def callbacks_methods_module
          @callbacks_methods_module ||= T.let(
            api.create_module(CallbacksMethodsModuleName),
            T.nilable(RBI::Scope),
          )
        end

        sig { returns(RBI::Scope) }
        def request_response_methods_module
          @request_response_methods_module ||= T.let(
            api.create_module(RequestResponseMethodsModuleName),
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
          api.create_extend(CallbacksMethodsModuleName)
          api.create_extend(RequestResponseMethodsModuleName)
          api.create_extend(RoutingMethodsModuleName)
          create_api_class
          create_endpoint_class
        end

        sig { void }
        def create_api_class
          superclass = "::Grape::API::Instance"

          api.create_class(APIInstanceClassName, superclass_name: superclass) do |klass|
            klass.create_extend(CallbacksMethodsModuleName)
            klass.create_extend(RequestResponseMethodsModuleName)
            klass.create_extend(RoutingMethodsModuleName)
          end
        end

        sig { void }
        def create_endpoint_class
          superclass = "::Grape::Endpoint"

          named_helper_mods = constant.namespace_stackable(:helpers).reject { |mod| mod.name.nil? }

          api.create_class(EndpointClassName, superclass_name: superclass) do |klass|
            named_helper_mods.each do |mod|
              klass.create_include(mod.name)
            end
          end
        end

        sig { void }
        def create_callbacks_methods
          CALLBACKS_METHODS.each do |callback|
            callbacks_methods_module.create_method(
              callback.to_s,
              parameters: [
                create_block_param("block", type: "T.proc.bind(#{EndpointClassName}).void"),
              ],
              return_type: "void",
            )
          end
        end

        sig { void }
        def create_request_response_methods
          request_response_methods_module.create_method("rescue_from") do |method|
            method.add_rest_param("args")
            method.add_block_param("block")

            method.add_sig do |sig|
              sig.add_param("args", "Symbol")
              sig.add_param("block", "T.nilable(T.proc.bind(#{EndpointClassName}).params(e: Exception).void)")
              sig.return_type = "void"
            end
            method.add_sig(type_params: ["E"]) do |sig|
              sig.add_param("args", "T::Class[T.all(::Exception, T.type_parameter(:E))]")
              sig.add_param(
                "block",
                "T.nilable(T.proc.bind(#{EndpointClassName}).params(e: T.type_parameter(:E)).void)",
              )
              sig.return_type = "void"
            end
          end
        end

        sig { void }
        def create_routing_methods
          # https://github.com/ruby-grape/grape/blob/v2.4.0/lib/grape/dsl/routing.rb#L135-L163
          routing_methods_module.create_method(
            "route",
            parameters: [
              create_param("methods", type: "T.untyped"),
              create_opt_param("paths", type: "T.untyped", default: "['/']"),
              create_opt_param("route_options", type: "T::Hash[Symbol, T.untyped]", default: "{}"),
              create_block_param("block", type: "T.nilable(T.proc.bind(#{EndpointClassName}).void)"),
            ],
            return_type: "void",
          )

          # https://github.com/ruby-grape/grape/blob/v2.4.0/lib/grape/dsl/routing.rb#L165-L171
          HTTP_VERB_METHODS.each do |verb|
            routing_methods_module.create_method(
              verb.to_s,
              parameters: [
                create_rest_param("args", type: "T.untyped"),
                create_block_param("block", type: "T.nilable(T.proc.bind(#{EndpointClassName}).void)"),
              ],
              return_type: "void",
            )
          end

          # https://github.com/ruby-grape/grape/blob/v2.4.0/lib/grape/dsl/routing.rb#L173-L193
          NAMESPACE_METHODS.each do |namespace_method|
            routing_methods_module.create_method(
              namespace_method.to_s,
              parameters: [
                create_opt_param("space", type: "T.untyped", default: "nil"),
                create_opt_param("options", type: "T::Hash[Symbol, T.untyped]", default: "{}"),
                create_block_param("block", type: "T.nilable(T.proc.bind(T.class_of(#{APIInstanceClassName})).void)"),
              ],
              return_type: "void",
            )
          end

          # https://github.com/ruby-grape/grape/blob/v2.4.0/lib/grape/dsl/routing.rb#L215-L232
          routing_methods_module.create_method(
            "route_param",
            parameters: [
              create_param("param", type: "Symbol"),
              create_opt_param("options", type: "T::Hash[Symbol, T.untyped]", default: "{}"),
              create_block_param("block", type: "T.nilable(T.proc.bind(T.class_of(#{APIInstanceClassName})).void)"),
            ],
            return_type: "void",
          )
        end
      end
    end
  end
end
