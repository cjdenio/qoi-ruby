# frozen_string_literal: true

require_relative "lib/qoif/version"

Gem::Specification.new do |spec|
  spec.name = "qoif"
  spec.version = Qoif::VERSION
  spec.authors = ["Caleb Denio"]
  spec.email = ["cjdenio44@gmail.com"]

  spec.summary = "qoif"
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = "https://github.com/cjdenio/qoif-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/cjdenio/qoif-ruby"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "chunky_png"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
