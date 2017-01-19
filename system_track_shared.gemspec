#gem build system_track_shared.gemspec
#gem inabox ./system-track-shared-1.5.gem -g http://gemserver.openlogic.local:10080

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'system_track_shared/version'

Gem::Specification.new do |spec|
  spec.name          = "system-track-shared"
  spec.version       = SystemTrack::VERSION
  spec.authors       = ["Mike Moore"]
  spec.email         = ["mike.moore@roguewave.com"]

  spec.summary       = "System Track files shared among all services"
  spec.description   = "System Track files shared among all services"
 # spec.homepage      = "My Homepage"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

#  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files = Dir.glob("{bin,lib}/**/*")
  spec.files <<    "lib/system_track_shared.rb"  
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "lib/system_track_shared.rb"]

  spec.add_runtime_dependency 'faraday'
end
