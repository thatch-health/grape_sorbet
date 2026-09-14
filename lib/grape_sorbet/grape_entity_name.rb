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
    # Used by grape-swagger and grape-oas to define a custom name to use in the OpenAPI schema instead of generating
    # it from the fully qualified class name.
    #
    # @param entity_name [String] The custom entity name.
    sig { params(entity_name: String).void }
    def entity_name=(entity_name)
      @entity_name = T.let(entity_name, T.nilable(String))

      # Define the `entity_name` reader method on the calling class for the benefit of grape-oas.
      # Previously, grape_sorbet defined the `entity_name` reader method directly in this module, but that caused
      # an issue with grape-oas when using class inheritance.
      #
      # Relevant code: https://github.com/numbata/grape-oas/blob/v1.4.0/lib/grape_oas/introspectors/entity_introspector_support.rb#L35-L54

      define_singleton_method(:entity_name) { @entity_name }

      nil
    end

    sig { params(method_name: T.any(String, Symbol), include_all: T::Boolean).returns(T::Boolean) }
    def respond_to?(method_name, include_all = false)
      return super unless method_name.to_sym == :entity_name

      # It is possible for `entity_name` to be defined but `@entity_name` to be nil, for example if a parent class has
      # called `entity_name=` but the child class has not. In that case, we want to return false to avoid grape-swagger
      # thinking an entity name has been set when it hasn't.
      #
      # Relevant code: https://github.com/ruby-grape/grape-swagger/blob/v2.1.4/lib/grape-swagger/doc_methods/data_type.rb#L51-L52

      !!(defined?(@entity_name) && !@entity_name.nil?)
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
