# typed: strict
# frozen_string_literal: true

begin
  require "grape-entity"
rescue LoadError
  return
end

require "sorbet-runtime"

module GrapeSorbet
  # A Sorbet-typed version of `Grape::Entity`.
  #
  # This class works like `Grape::Entity`, with a few key differences:
  # - `expose` can only be used for basic exposure of attributes, and can only expose one attribute at a time.
  # - For runtime exposure, use `expose_runtime` instead of `expose`.
  # - For nested exposure, use `expose_nested` instead of `expose`.
  #
  # In order for Sorbet to know the type of the object being exposed in runtime exposures (i.e. the first argument to
  # the exposure block), you need to use `ObjectTypeTemplate`.
  #
  # In order for Sorbet to know the type of the object being exposed in helper methods via `object`, you need to set
  # `ObjectTypeMember`.
  #
  # You don't have to set both, e.g. there is no need to set `ObjectTypeMember` if your entity does not have any helper
  # methods calling `object`. However, if you do set both, they should always be set to the same type.
  #
  # Example:
  # ```
  # module API
  #   module Entities
  #     class User < GrapeSorbet::TypedEntity
  #       ObjectTypeMember = type_member { { fixed: ::User } }
  #       ObjectTypeTemplate = type_template { { fixed: ::User } }
  #
  #       expose :id
  #
  #       expose_runtime :name do |user|
  #         # T.reveal_type(user) # => ::User
  #         user.profile.name
  #       end
  #
  #       expose_nested :contact_info do
  #         expose_runtime :phone do |user|
  #           user.profile.phone_number
  #         end
  #       end
  #
  #       expose :number_of_friends
  #
  #       private
  #
  #       sig { returns(Integer) }
  #       def number_of_friends
  #         # T.reveal_type(object) # => User
  #         object.friends.count
  #       end
  #     end
  #   end
  # end
  # ```
  class TypedEntity < Grape::Entity
    extend T::Sig
    extend T::Helpers
    extend T::Generic

    abstract!

    ObjectTypeMember = type_member
    ObjectTypeTemplate = type_template

    class << self
      extend T::Sig

      sig { params(attribute: Symbol, options: T::Hash[Symbol, T.untyped]).void }
      def expose(attribute, options = {})
        super(attribute, options)
      end

      sig do
        params(
          attribute: Symbol,
          options: T::Hash[Symbol, T.untyped],
          block: T.proc.bind(T.attached_class).params(
            object: ObjectTypeTemplate,
            options: T::Hash[Symbol, T.untyped],
          ).returns(T.untyped),
        ).void
      end
      def expose_runtime(attribute, options = {}, &block)
        T.must(method(:expose).super_method).call(attribute, options, &block)
      end

      sig do
        params(
          attribute: Symbol,
          options: T::Hash[Symbol, T.untyped],
          block: T.proc.bind(T.self_type).void,
        ).void
      end
      def expose_nested(attribute, options = {}, &block)
        T.must(method(:expose).super_method).call(attribute, options, &block)
      end
    end

    sig { returns(ObjectTypeMember) }
    def object
      super
    end
  end
end
