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
      #     sig do
      #       params(
      #         args: T.untyped,
      #         options: T.untyped,
      #         block: T.nilable(T.proc.bind(PrivateEndpoint).void),
      #       )
      #       .void
      #     end
      #     def get(*args, **options, &block); end
      #
      #     # ...
      #
      #     sig do
      #       params(
      #         param: Symbol,
      #         requirements: T.untyped,
      #         type: T.untyped,
      #         options: T.untyped,
      #         block: T.nilable(T.proc.bind(T.class_of(PrivateAPIInstance)).void),
      #       ).void
      #     end
      #     def route_param(param, requirements: nil, type: nil, **options, &block); end
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
          api_class_name = constant.name
          return unless api_class_name

          root.create_class(api_class_name) do |api|
            create_classes_and_includes(api)

            create_callbacks_methods(api)
            create_request_response_methods(api)
            create_routing_methods(api)
          end
        end

        class << self
          extend T::Sig

          sig { override.returns(T::Enumerable[T.class_of(::Grape::API::Instance)]) }
          def gather_constants
            descendants_of(::Grape::API::Instance)
          end
        end

        # https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/callbacks.rb#L12-L16
        CALLBACKS_METHODS = T.let(
          [:before, :before_validation, :after_validation, :after, :finally].freeze,
          T::Array[Symbol],
        )

        # https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape.rb#L56-L64
        HTTP_VERB_METHODS = T.let(
          [:get, :post, :put, :patch, :delete, :head, :options].freeze,
          T::Array[Symbol],
        )

        # https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L189-L214
        NAMESPACE_METHODS = T.let(
          [:namespace, :group, :resource, :resources, :segment].freeze,
          T::Array[Symbol],
        )

        private

        sig { params(api: RBI::Scope).void }
        def create_classes_and_includes(api)
          api.create_extend(CallbacksMethodsModuleName)
          api.create_extend(RequestResponseMethodsModuleName)
          api.create_extend(RoutingMethodsModuleName)
          create_api_class(api)
          create_endpoint_class(api)
        end

        sig { params(api: RBI::Scope).void }
        def create_api_class(api)
          superclass = "::Grape::API::Instance"

          api.create_class(APIInstanceClassName, superclass_name: superclass) do |klass|
            klass.create_extend(CallbacksMethodsModuleName)
            klass.create_extend(RequestResponseMethodsModuleName)
            klass.create_extend(RoutingMethodsModuleName)
          end
        end

        sig { params(api: RBI::Scope).void }
        def create_endpoint_class(api)
          superclass = "::Grape::Endpoint"

          named_helper_mods = constant.inheritable_setting.namespace_stackable[:helpers].reject { |mod| mod.name.nil? }

          api.create_class(EndpointClassName, superclass_name: superclass) do |klass|
            named_helper_mods.each do |mod|
              klass.create_include(mod.name)
            end
          end
        end

        sig { params(api: RBI::Scope).void }
        def create_callbacks_methods(api)
          api.create_module(CallbacksMethodsModuleName) do |mod|
            # https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/callbacks.rb#L12-L16
            CALLBACKS_METHODS.each do |callback|
              mod.create_method(
                callback.to_s,
                parameters: [
                  create_block_param("block", type: "T.proc.bind(#{EndpointClassName}).void"),
                ],
                return_type: "void",
              )
            end
          end
        end

        sig { params(api: RBI::Scope).void }
        def create_request_response_methods(api)
          api.create_module(RequestResponseMethodsModuleName) do |mod|
            # https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/request_response.rb#L76-L127
            mod.create_method("rescue_from") do |method|
              method.add_rest_param("args")
              method.add_kw_rest_param("options")
              method.add_block_param("block")

              method.add_sig do |sig|
                sig.add_param("args", "Symbol")
                # Sorbet doesn't support keyword arguments in overloaded functions :(
                # sig.add_param("options", "T.untyped")
                sig.add_param("block", "T.nilable(T.proc.bind(#{EndpointClassName}).params(e: Exception).void)")
                sig.return_type = "void"
              end
              method.add_sig(type_params: ["E"]) do |sig|
                sig.add_param("args", "T::Class[T.all(::Exception, T.type_parameter(:E))]")
                sig.add_param("options", "T.untyped")
                sig.add_param(
                  "block",
                  "T.nilable(T.proc.bind(#{EndpointClassName}).params(e: T.type_parameter(:E)).void)",
                )
                sig.return_type = "void"
              end
            end
          end
        end

        sig { params(api: RBI::Scope).void }
        def create_routing_methods(api)
          api.create_module(RoutingMethodsModuleName) do |routing_methods_module|
            # https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L148-L180
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

            # https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L182-L187
            HTTP_VERB_METHODS.each do |verb|
              routing_methods_module.create_method(
                verb.to_s,
                parameters: [
                  create_rest_param("args", type: "T.untyped"),
                  create_kw_rest_param("options", type: "T.untyped"),
                  create_block_param("block", type: "T.nilable(T.proc.bind(#{EndpointClassName}).void)"),
                ],
                return_type: "void",
              )
            end

            # https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L189-L214
            NAMESPACE_METHODS.each do |namespace_method|
              routing_methods_module.create_method(
                namespace_method.to_s,
                parameters: [
                  create_opt_param("space", type: "T.untyped", default: "nil"),
                  create_kw_opt_param("requirements", type: "T.untyped", default: "nil"),
                  create_kw_rest_param("options", type: "T.untyped"),
                  create_block_param("block", type: "T.nilable(T.proc.bind(T.class_of(#{APIInstanceClassName})).void)"),
                ],
                return_type: "void",
              )
            end

            # https://github.com/ruby-grape/grape/blob/v3.2.0/lib/grape/dsl/routing.rb#L221-L234
            routing_methods_module.create_method(
              "route_param",
              parameters: [
                create_param("param", type: "Symbol"),
                create_kw_opt_param("requirements", type: "T.untyped", default: "nil"),
                create_kw_opt_param("type", type: "T.untyped", default: "nil"),
                create_kw_rest_param("options", type: "T.untyped"),
                create_block_param("block", type: "T.nilable(T.proc.bind(T.class_of(#{APIInstanceClassName})).void)"),
              ],
              return_type: "void",
            )
          end
        end
      end
    end
  end
end
