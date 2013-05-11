lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wipe_free_space/version'

Gem::Specification.new do |spec|
  spec.name          = "wipe_free_space"
  spec.version       = WipeFreeSpace::VERSION
  spec.authors       = ["Ruafozy"]
  spec.summary       = %q{Wipe unused space on disk filesystems.}
  spec.description   = %q{
    This gem contains a program which temporarily fills up disk
    filesystems, thus overwriting sensitive material from deleted files.
  }
  spec.homepage =
    "https://github.com/ruafozy/utils/tree/master/wipe-free-space"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/) - %w{
    Gemfile
  }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  [
    ['methadone', ['~> 1.2.6']],
    ['sys-filesystem', ['~> 1.1.0']],
  ].each do |name, ver|
    spec.add_runtime_dependency(name, ver)
  end

  spec.add_development_dependency "minitest", '~> 4.0'
end
