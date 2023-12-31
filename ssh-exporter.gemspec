lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ssh-exporter/version'

Gem::Specification.new do |s|
  s.name          = 'ssh-exporter'
  s.version       = SshExporter::VERSION

  s.summary       =
  s.description   = 'Generate metrics by connecting to systems over SSH'
  s.authors       = 'Jakub Skokan'
  s.email         = 'jakub.skokan@vpsfree.cz'
  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']
  s.license       = 'MIT'

  s.required_ruby_version = '>= 2.7.0'

  s.add_runtime_dependency 'prometheus-client', '~> 4.0.0'
  s.add_runtime_dependency 'thin', '~> 1.8.1'
  s.add_development_dependency 'rake'
end
