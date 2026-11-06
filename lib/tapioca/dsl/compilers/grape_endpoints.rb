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
      # For a `helpers do ... end` block, the compiler copies the methods of the block into `PrivateEndpoint`.
      # It also includes the endpoint DSL modules in `API`, because Sorbet puts the methods of the block in `API`.
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
            create_helper_context(api)

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

        # https://github.com/ruby-grape/grape/blob/v4.0.0/lib/grape/dsl/callbacks.rb#L12-L16
        CALLBACKS_METHODS = [:before, :before_validation, :after_validation, :after, :finally].freeze

        # https://github.com/ruby-grape/grape/blob/v4.0.0/lib/grape.rb#L69-L78
        HTTP_VERB_METHODS = [:get, :query, :post, :put, :patch, :delete, :head, :options].freeze

        # https://github.com/ruby-grape/grape/blob/v4.0.0/lib/grape/dsl/routing.rb#L219-L246
        NAMESPACE_METHODS = [:namespace, :group, :resource, :resources, :segment].freeze

        # https://github.com/ruby-grape/grape/blob/v4.0.1/lib/grape/endpoint.rb#L10-L12
        ENDPOINT_MODULES = ["::Grape::DSL::Settings", "::Grape::DSL::Headers", "::Grape::DSL::InsideRoute"].freeze

        # https://github.com/ruby-grape/grape/blob/v4.0.1/lib/grape/endpoint.rb#L14-L26
        ENDPOINT_READERS = T.let(
          {
            "api" => "T.untyped",
            "cookies" => "T.untyped",
            "env" => "T.untyped",
            "logger" => "T.untyped",
            "options" => "T.untyped",
            "params" => "T.untyped",
            "request" => "::Grape::Request",
            "response_cookies" => "T.untyped",
            "source" => "T.untyped",
          }.freeze,
          T::Hash[String, String],
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
          superclass = superclass_of(constant)&.name || "::Grape::API::Instance"

          api.create_class(APIInstanceClassName, superclass_name: superclass) do |klass|
            klass.create_extend(CallbacksMethodsModuleName)
            klass.create_extend(RequestResponseMethodsModuleName)
            klass.create_extend(RoutingMethodsModuleName)
          end
        end

        sig { params(api: RBI::Scope).void }
        def create_endpoint_class(api)
          superclass = "::Grape::Endpoint"

          api.create_class(EndpointClassName, superclass_name: superclass) do |klass|
            named_helper_modules.each do |mod|
              klass.create_include(T.must(mod.name))
            end

            # Grape includes the module of a `helpers` block into the endpoint, but the module has no name.
            # Thus, copy its methods.
            anonymous_helper_methods.each do |method_def, visibility|
              klass.create_method(
                method_def.name.to_s,
                parameters: compile_method_parameters_to_rbi(method_def),
                return_type: compile_method_return_type_to_rbi(method_def),
                visibility: visibility,
              )
            end
          end
        end

        # Sorbet puts the methods of a `helpers` block in the API class, not in the endpoint.
        # Thus, give the API class the endpoint methods that these helper methods can call.
        sig { params(api: RBI::Scope).void }
        def create_helper_context(api)
          return if anonymous_helper_methods.empty?

          ENDPOINT_MODULES.each { |mod| api.create_include(mod) }
          named_helper_modules.each { |mod| api.create_include(T.must(mod.name)) }

          helper_method_names = anonymous_helper_methods.map { |method_def, _| method_def.name.to_s }
          ENDPOINT_READERS.each do |name, type|
            next if helper_method_names.include?(name)

            api.create_method(name, return_type: type)
          end
        end

        sig { returns(T::Array[T::Module[T.anything]]) }
        def named_helper_modules
          @named_helper_modules ||= T.let(
            helper_modules.reject { |mod| mod.name.nil? },
            T.nilable(T::Array[T::Module[T.anything]]),
          )
        end

        sig { returns(T::Array[[UnboundMethod, RBI::Visibility]]) }
        def anonymous_helper_methods
          @anonymous_helper_methods ||= T.let(
            helper_modules.select { |mod| mod.name.nil? }.flat_map do |mod|
              public_methods = mod.public_instance_methods(false).map { |name| [name, RBI::Public.new] }
              private_methods = mod.private_instance_methods(false).map { |name| [name, RBI::Private.new] }

              (public_methods + private_methods).map { |name, visibility| [mod.instance_method(name), visibility] }
            end.sort_by { |method_def, _| method_def.name },
            T.nilable(T::Array[[UnboundMethod, RBI::Visibility]]),
          )
        end

        sig { returns(T::Array[T::Module[T.anything]]) }
        def helper_modules
          constant.inheritable_setting.helpers
        end

        sig { params(api: RBI::Scope).void }
        def create_callbacks_methods(api)
          api.create_module(CallbacksMethodsModuleName) do |mod|
            # https://github.com/ruby-grape/grape/blob/v4.0.0/lib/grape/dsl/callbacks.rb#L12-L16
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
            # https://github.com/ruby-grape/grape/blob/v4.0.0/lib/grape/dsl/request_response.rb#L95-L126
            mod.create_method("rescue_from") do |method|
              method.add_rest_param("args")
              method.add_kw_opt_param("with", "nil")
              method.add_kw_opt_param("rescue_subclasses", "true")
              method.add_kw_opt_param("backtrace", "false")
              method.add_kw_opt_param("original_exception", "false")
              method.add_block_param("block")

              method.add_sig do |sig|
                sig.add_param("args", "Symbol")
                # Sorbet doesn't support keyword arguments in overloaded functions :(
                # sig.add_param("with", "T.untyped")
                # sig.add_param("rescue_subclasses", "T::Boolean")
                # sig.add_param("backtrace", "T::Boolean")
                # sig.add_param("original_exception", "T::Boolean")
                sig.add_param("block", "T.nilable(T.proc.bind(#{EndpointClassName}).params(e: Exception).void)")
                sig.return_type = "void"
              end

              method.add_sig(type_params: ["E"]) do |sig|
                sig.add_param("args", "T::Class[T.all(::Exception, T.type_parameter(:E))]")
                sig.add_param("with", "T.untyped")
                sig.add_param("rescue_subclasses", "T::Boolean")
                sig.add_param("backtrace", "T::Boolean")
                sig.add_param("original_exception", "T::Boolean")
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
            # https://github.com/ruby-grape/grape/blob/v4.0.0/lib/grape/dsl/routing.rb#L168-L211
            routing_methods_module.create_method(
              "route",
              parameters: [
                create_param("methods", type: "T.any(Symbol, String, T::Array[String])"),
                create_opt_param("paths", type: "T.nilable(T.any(String, T::Array[String]))", default: "['/']"),
                create_kw_opt_param("requirements", type: "T.nilable(T::Hash[Symbol, T.untyped])", default: "nil"),
                create_kw_opt_param("anchor", type: "T::Boolean", default: "true"),
                create_kw_rest_param("route_options", type: "T.untyped"),
                create_block_param("block", type: "T.nilable(T.proc.bind(#{EndpointClassName}).void)"),
              ],
              return_type: "void",
            )

            # https://github.com/ruby-grape/grape/blob/v4.0.0/lib/grape/dsl/routing.rb#L213-L217
            HTTP_VERB_METHODS.each do |verb|
              routing_methods_module.create_method(
                verb.to_s,
                parameters: [
                  create_opt_param("path", type: "String", default: "'/'"),
                  create_kw_rest_param("options", type: "T.untyped"),
                  create_block_param("block", type: "T.nilable(T.proc.bind(#{EndpointClassName}).void)"),
                ],
                return_type: "void",
              )
            end

            # https://github.com/ruby-grape/grape/blob/v4.0.0/lib/grape/dsl/routing.rb#L219-L246
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

            # https://github.com/ruby-grape/grape/blob/v4.0.0/lib/grape/dsl/routing.rb#L253-L271
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
