# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mc-limit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tim Jensen"]
  gem.email         = ["tim.l.jensen@gmail.com"]
  gem.description   = %q{Minecraft Limiter (mc-limit) launches Minecraft in offline mode and automatically terminates the game after it has been played for a pre-determined amount of time.}
  gem.summary       = %q{Limit the amount of time Minecraft can be played per day}
  gem.homepage      = "https://github.com/tjensen/mc-limit"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mc-limit"
  gem.require_paths = ["lib"]
  gem.version       = MCLimit::VERSION

  gem.platform = Gem::Platform::CURRENT
  gem.required_ruby_version = ">= 1.9.1"

  gem.add_dependency('sys-proctable')
  gem.add_dependency('win32-api')
  gem.add_dependency('wxruby-ruby19')
end
