# typed: strict
# frozen_string_literal: true

require "spec_helper"

module Grape
  class EntitySpec < Minitest::Spec
    describe "Grape::Entity" do
      before do
        @fresh_class = T.let(
          T.unsafe(Class).new(Grape::Entity),
          T.all(T.class_of(Grape::Entity), GrapeSorbet::GrapeEntityName),
        )
      end

      describe "class methods" do
        describe ".entity_name" do
          it "returns the custom entity name if one has been set" do
            @fresh_class.entity_name = "CustomEntityName"
            assert_equal("CustomEntityName", @fresh_class.entity_name)
          end

          it "raises an error if no custom entity name has been set" do
            e = assert_raises(StandardError) { @fresh_class.entity_name }
            assert_match(/entity_name has not been set/, e.message)
          end
        end

        describe ".entity_name=" do
          it "sets the entity name" do
            refute(@fresh_class.instance_variable_defined?(:@entity_name))

            @fresh_class.entity_name = "CustomEntityName"

            assert(@fresh_class.instance_variable_defined?(:@entity_name))
            assert_equal("CustomEntityName", @fresh_class.instance_variable_get(:@entity_name))
          end
        end

        describe ".respond_to?" do
          it "returns true for entity_name if a custom entity name has been set" do
            @fresh_class.entity_name = "CustomEntityName"
            assert(@fresh_class.respond_to?(:entity_name))
          end

          it "returns false for entity_name if no custom entity name has been set" do
            refute(@fresh_class.respond_to?(:entity_name))
          end
        end
      end
    end
  end
end
