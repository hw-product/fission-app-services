$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-app-services/version'
Gem::Specification.new do |s|
  s.name = 'fission-app-services'
  s.version = FissionApp::Services::VERSION.version
  s.summary = 'Fission App Services'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/hw-product/fission-app-services'
  s.description = 'Fission backend service setup UI'
  s.require_path = 'lib'
  s.add_dependency 'fission-data'
  s.add_dependency 'fission-app'
  s.files = Dir['{lib,app,config}/**/**/*'] + %w(fission-app-services.gemspec README.md CHANGELOG.md)
end
