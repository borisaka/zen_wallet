# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zen_wallet/version'

Gem::Specification.new do |spec|
  spec.name          = "zen_wallet"
  spec.version       = ZenWallet::VERSION
  spec.authors       = ["Boris A. Kraportov"]
  spec.email         = ["boris.kraportov@gmail.com"]

  spec.summary       = %q{Bip38 multiaccount wallet lib with sql keystore}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/borisaka/zen_wallet"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sequel", "~> 4.42"
  spec.add_runtime_dependency "bitcoin-ruby", "~> 0.0.9"
  spec.add_runtime_dependency "btcruby", "~> 1.6"
  spec.add_runtime_dependency "money-tree", "~> 0.9.0"
  spec.add_runtime_dependency "scrypt", "~> 3.0"
  spec.add_runtime_dependency "dry-configurable", "~> 0.5.0"
  spec.add_runtime_dependency "dry-initializer", "~> 0.11.0"
  spec.add_runtime_dependency "dry-equalizer", "~> 0.2.0"
  spec.add_runtime_dependency "dry-monads", "~> 0.2.1"
  spec.add_runtime_dependency "dry-types", "~> 0.9.3"
  spec.add_runtime_dependency "faraday", "~> 0.11.0"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop", "0.46.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-rescue"
  spec.add_development_dependency "pry-stack_explorer"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "pry-coolline"
  spec.add_development_dependency "pry-inline"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "pry-state"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "m"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "mocha", "~> 1.2.1"
  spec.add_development_dependency "webmock", "~> 2.3.2"
end
