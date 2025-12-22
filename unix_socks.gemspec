# -*- encoding: utf-8 -*-
# stub: unix_socks 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "unix_socks".freeze
  s.version = "0.2.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "1980-01-02"
  s.description = "This library enables communication between processes using Unix sockets. It\nhandles message transmission, socket management, and cleanup, supporting\nboth synchronous and asynchronous operations while providing error handling\nfor robust development.\n".freeze
  s.email = "flori@ping.de".freeze
  s.extra_rdoc_files = ["README.md".freeze, "lib/unix_socks.rb".freeze, "lib/unix_socks/message.rb".freeze, "lib/unix_socks/server.rb".freeze, "lib/unix_socks/version.rb".freeze]
  s.files = ["CHANGES.md".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "lib/unix_socks.rb".freeze, "lib/unix_socks/message.rb".freeze, "lib/unix_socks/server.rb".freeze, "lib/unix_socks/version.rb".freeze, "spec/spec_helper.rb".freeze, "spec/unix_socks/message_spec.rb".freeze, "spec/unix_socks/server_spec.rb".freeze, "unix_socks.gemspec".freeze]
  s.homepage = "https://github.com/flori/unix_socks".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--title".freeze, "UnixSocks - A Ruby library for inter-process communication via Unix sockets with\ndynamic message handling\n".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.1".freeze)
  s.rubygems_version = "4.0.2".freeze
  s.summary = "A Ruby library for inter-process communication via Unix sockets with dynamic message handling".freeze
  s.test_files = ["spec/spec_helper.rb".freeze, "spec/unix_socks/message_spec.rb".freeze, "spec/unix_socks/server_spec.rb".freeze]

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 2.14".freeze])
  s.add_development_dependency(%q<all_images>.freeze, ["~> 0.4".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.2".freeze])
  s.add_development_dependency(%q<debug>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<yard>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<json>.freeze, ["~> 2.0".freeze])
  s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.3".freeze])
end
