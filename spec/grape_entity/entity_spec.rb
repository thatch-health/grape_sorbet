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
        describe ".entity_name=" do
          it "defines an entity_name reader method" do
            refute(@fresh_class.respond_to?(:entity_name))

            @fresh_class.entity_name = "CustomEntityName"

            assert(@fresh_class.respond_to?(:entity_name))
            assert_equal("CustomEntityName", T.unsafe(@fresh_class).entity_name)
          end

          it "overwrites an existing entity_name method if it exists" do
            @fresh_class.entity_name = "FirstEntityName"

            assert(@fresh_class.respond_to?(:entity_name))
            assert_equal("FirstEntityName", T.unsafe(@fresh_class).entity_name)

            Warning.expects(:warn).at_least_once

            @fresh_class.entity_name = "SecondEntityName"

            assert(@fresh_class.respond_to?(:entity_name))
            assert_equal("SecondEntityName", T.unsafe(@fresh_class).entity_name)
          end

          it "handles class inheritance" do
            @fresh_class.entity_name = "ParentEntityName"
            assert(@fresh_class.respond_to?(:entity_name))
            assert_equal("ParentEntityName", T.unsafe(@fresh_class).entity_name)

            subclass = Class.new(@fresh_class)
            refute(subclass.respond_to?(:entity_name))

            subclass.entity_name = "ChildEntityName"
            assert_equal("ChildEntityName", T.unsafe(subclass).entity_name)
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

          it "returns false for entity_name if the custom entity name was set on a parent class" do
            @fresh_class.entity_name = "ParentEntityName"
            assert(@fresh_class.respond_to?(:entity_name))

            subclass = Class.new(@fresh_class)
            refute(subclass.respond_to?(:entity_name))
          end
        end
      end
    end
  end
end
