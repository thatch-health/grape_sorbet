# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module GrapeSorbet
  # This is a patch for Grape::Entity to make it easier to define custom entity names when using Sorbet.
  #
  # This patch defines a class setter `entity_name=` that can be used to define a custom entity name in a single line,
  # while still working as expected with grape-swagger:
  # ```
  # class Link < Grape::Entity
  #   self.entity_name = "LinkedStatus"
  # end
  # ```
  #
  # Without this patch, you would have to define a custom entity name like this:
  # ```
  # class Link < Grape::Entity
  #   extend T::Sig
  #
  #   sig { returns(String) }
  #   def self.entity_name
  #     "LinkedStatus"
  #   end
  # end
  # ```
  #
  # or even more verbose, if you're using the `Style/ClassMethodsDefinitions` Rubocop rule with
  # `EnforcedStyle: self_class`:
  # ```
  # class Link < Grape::Entity
  #   class << self
  #     extend T::Sig
  #
  #     sig { returns(String) }
  #     def entity_name
  #       "LinkedStatus"
  #     end
  #   end
  # end
  # ```
  module GrapeEntityName
    extend T::Sig

    include Kernel

    # Sets the entity name.
    #
    # Used by grape-swagger to define a custom name to use in the OpenAPI schema instead of generating it from the
    # fully qualified class name.
    #
    # @param entity_name [String] The custom entity name.
    sig { params(entity_name: String).returns(String) }
    attr_writer :entity_name

    # Returns the custom entity name if one has been set (using `entity_name=`), otherwise raises an error.
    #
    # @return [String] The custom entity name.
    # @raise [StandardError] If no custom entity name has been set.
    sig { returns(String) }
    def entity_name
      @entity_name = T.let(@entity_name, T.nilable(String))

      return @entity_name unless @entity_name.nil?

      raise "entity_name has not been set for #{self}, call `#{self}.entity_name = \"...\"` to set it"
    end

    sig { params(method_name: T.any(String, Symbol), include_all: T.untyped).returns(T::Boolean) }
    def respond_to?(method_name, include_all = false)
      # grape-swagger checks if the model class responds to `:entity_name`, so we need to return false if
      # `@entity_name` is nil (meaning `entity_name=` was never called).
      if method_name.to_sym == :entity_name
        return !!(defined?(@entity_name) && !@entity_name.nil?)
      end

      super
    end
  end
end

begin
  require "grape-entity"
rescue LoadError
  return
else
  Grape::Entity.extend(GrapeSorbet::GrapeEntityName)
end
