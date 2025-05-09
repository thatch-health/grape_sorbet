# typed: strict
# frozen_string_literal: true

require "spec_helper"

module GrapeSorbet
  class TypedEntitySpec < Minitest::Spec
    describe "GrapeSorbet::TypedEntity" do
      class Person < T::Struct
        const :name, String
        const :age, Integer
      end

      class PersonEntity < GrapeSorbet::TypedEntity
        ObjectTypeMember = type_member { { fixed: Person } }
        ObjectTypeTemplate = type_template { { fixed: Person } }

        expose :name

        expose_runtime :age do |person|
          # T.reveal_type(self) # => PersonEntity
          # T.reveal_type(person) # => Person
          age_in_years(person)
        end

        expose_nested :profile do
          # T.reveal_type(self) # => T.class_of(PersonEntity)
          expose :age
        end

        expose :age_squared

        private

        sig { params(person: Person).returns(String) }
        def age_in_years(person)
          "#{person.age} years"
        end

        sig { returns(Integer) }
        def age_squared
          # T.reveal_type(object) # => Person
          object.age * object.age
        end
      end

      describe ".expose" do
        it "exposes the attribute" do
          person = Person.new(name: "John", age: 30)
          entity = PersonEntity.represent(person)
          puts entity.to_json
          assert_equal("John", entity.as_json[:name])
        end
      end

      describe ".expose_runtime" do
        it "exposes the return value of the block exposure" do
          person = Person.new(name: "John", age: 30)
          entity = PersonEntity.represent(person)
          assert_equal("30 years", entity.as_json[:age])
        end
      end

      describe ".expose_nested" do
        it "can expose attributes from within the nested exposure" do
          person = Person.new(name: "John", age: 30)
          entity = PersonEntity.represent(person)
          assert_equal(30, entity.as_json[:profile][:age])
        end
      end

      describe "#object" do
        it "returns the object being represented" do
          person = Person.new(name: "John", age: 30)
          entity = PersonEntity.represent(person)
          assert_equal(person, entity.object)
        end
      end
    end
  end
end
