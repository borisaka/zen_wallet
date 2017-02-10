# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "zen_wallet/version"
require "yaml"

Gem::Specification.new do |spec|
  spec.name          = "zen_wallet"
  spec.version       = ZenWallet::VERSION
  spec.authors       = ["Boris A. Kraportov"]
  spec.email         = ["boris.kraportov@gmail.com"]
  spec.summary       = "Bip44 multiaccount wallet lib with sql keystore"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/borisaka/zen_wallet"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "http://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  dependencies = YAML.load_file("dependencies.yml")

  dependencies["runtime"].each do |g, v|
    spec.add_runtime_dependency(g, v)
  end
    
  dependencies["development"].each do |g, v|
    spec.add_development_dependency(g, v)
  end
end
