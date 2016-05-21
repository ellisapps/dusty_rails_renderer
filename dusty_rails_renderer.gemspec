# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dusty_rails_renderer/version'

Gem::Specification.new do |spec|
  spec.name          = "dusty_rails_renderer"
  spec.version       = DustyRailsRenderer::VERSION
  spec.authors       = "Louis Ellis"
  spec.email         = "Louis.f.ellis@gmail.com"

  spec.summary       = "Render Dust server side"
  spec.description   = "Render Dust server side"
  spec.homepage      = "https://github.com/ellisapps/dusty_rails_renderer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0" 
  spec.add_runtime_dependency 'libv8'
  spec.add_runtime_dependency 'therubyracer', '~> 0.12', '>= 0.12.2'
  spec.add_runtime_dependency "google_hash", "~> 0.9.0"
end
