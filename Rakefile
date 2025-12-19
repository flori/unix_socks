# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'unix_socks'
  module_type :module
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "https://github.com/flori/#{name}"
  summary     <<~EOT
    A Ruby library for inter-process communication via Unix sockets with
    dynamic message handling
  EOT
  description <<~EOT
    This library enables communication between processes using Unix sockets. It
    handles message transmission, socket management, and cleanup, supporting
    both synchronous and asynchronous operations while providing error handling
    for robust development.
  EOT
  test_dir    'spec'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', '.AppleDouble', '.bundle',
    '.yardoc', 'doc', 'tags', 'errors.lst', 'cscope.out', 'coverage', 'tmp',
    'yard'
  package_ignore '.all_images.yml', '.tool-versions', '.gitignore', 'VERSION',
    '.rspec', '.github'
  readme      'README.md'

  required_ruby_version  '>= 3.1'

  dependency             'json',        '~> 2.0'
  dependency             'tins',        '~> 1.3'
  development_dependency 'all_images',            '~> 0.4'
  development_dependency 'rspec',                 '~> 3.2'
  development_dependency 'debug'
  development_dependency 'simplecov'
  development_dependency 'yard'

  licenses << 'MIT'

  clobber 'coverage'
end
