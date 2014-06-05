# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-assert"
  spec.version       = "0.0.1"
  spec.authors       = ["Fukui ReTu"]
  spec.email         = ["s0232101@gmail.com"]
  spec.description   = %q{Output Filter plugin to assertion}
  spec.summary       = %q{Output Filter plugin to assertion}
  spec.homepage      = "https://github.com/fukuiretu/fluent-plugin-assert"
  spec.license       = "APL2.0"

  spec.rubyforge_project = "fluent-plugin-assert"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "fluentd"
end
