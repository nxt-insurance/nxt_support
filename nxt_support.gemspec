lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nxt_support/version"

Gem::Specification.new do |spec|
  spec.name          = "nxt_support"
  spec.version       = NxtSupport::VERSION
  spec.authors       = ["Nils Sommer", "Andreas Robecke", "Nicolai Stoianov", "Akihiko Ito"]
  spec.email         = ["mail@nilssommer.de", "a.robecke@getsafe.de", "n.stoianov@hellogetsafe.com", "abc@akihiko.eu"]

  spec.summary       = "Support through reusable Mixins and Helpers for Ruby on Rails Applications"
  spec.homepage      = "https://github.com/nxt-insurance/nxt_support"
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nxt-insurance/nxt_support"
  spec.metadata["changelog_uri"] = "https://github.com/nxt-insurance/nxt_support/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_dependency "activesupport"
  spec.add_dependency "nxt_init"
  spec.add_dependency "nxt_registry"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pry"
end
