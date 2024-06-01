# typed: strict
# frozen_string_literal: true

require "tapioca/internal"
require "minitest/autorun"
require "minitest/spec"
require "minitest/reporters"

require "tapioca/helpers/test/content"
require "tapioca/helpers/test/template"
require "tapioca/helpers/test/isolation"
require "dsl_spec_helper"

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new)

module Minitest
  class Test
    extend T::Sig
  end
end
