# frozen_string_literal: true

require_relative "lib/grape_sorbet/version"

Gem::Specification.new do |spec|
  spec.name = "grape_sorbet"
  spec.version = GrapeSorbet::VERSION
  spec.authors = ["Thatch Health, Inc."]
  spec.email = ["grape-sorbet@thatch.ai"]

  spec.summary = "Sorbet signatures and Tapioca DSL compiler for Grape."
  spec.description = "This gem provides Sorbet signatures and a Tapioca DSL compiler that enable using " \
    "the Grape API framework in a Sorbet-typed Ruby project."
  spec.homepage = "https://github.com/thatch-health/grape_sorbet"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/thatch-health/grape_sorbet/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    %x(git ls-files -z).split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features|sorbet)/|\.(?:git|circleci|vscode)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_runtime_dependency("activesupport")
  spec.add_runtime_dependency("grape", "~> 2.0")
  spec.add_runtime_dependency("sorbet-runtime", "~> 0.5.10741")

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
