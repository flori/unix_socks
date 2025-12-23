# Changes

## 2025-12-23 v0.2.2

- Updated `gem_hadar` development dependency to version **2.15.0** or higher

## 2025-12-23 v0.2.1

- Updated `receive_in_background` method to validate socket file existence
  before thread creation and raise `Errno::EEXIST` in the calling thread
  instead of the background thread
- Added comprehensive test case for `receive_in_background` to verify proper
  exception propagation when socket already exists
- Enhanced documentation for `receive_in_background` method with clearer description and parameter details
- Improved documentation line wrapping for UnixSocks server methods
- Added detailed documentation for JSON message parsing and popping functionality
- Added changelog generation support via `changelog` block in `Rakefile`
- Updated `gem_hadar` development dependency from version **2.10** to **2.14**

## 2025-12-20 v0.2.0

- Updated `required_ruby_version` from `~> 3.1` to `>= 3.1` in `Rakefile` and
  `unix_socks.gemspec` to allow installation on Ruby **3.1** and higher
  versions
- Updated `rubygems` version from **3.6.9** to **4.0.2** in
  `unix_socks.gemspec`
- Updated `gem_hadar` development dependency from ~> **2.2** to ~> **2.10** in
  `unix_socks.gemspec`
- Added `openssl-dev` package to the Dockerfile for building
- Updated `bundle` command to `bundle update --all` and added `bundle install
  --jobs=$(getconf _NPROCESSORS_ONLN)` for parallel installation
- Added `fail_fast: true` option to the configuration
- Added `ruby:4.0-rc-alpine` image to the test matrix
- Installed `bundler` and `gem_hadar` gems using `gem install` in the
  Dockerfile

## 2025-09-07 v0.1.0

- Introduced `UnixSocks::Server.default_runtime_dir` class method
- Simplified coverage configuration by using `GemHadar::SimpleCov.start`

## 2025-07-13 v0.0.1

* Modify server to use `at_exit` for socket cleanup:
  * Replace direct call to `remove_socket_path` with an `at_exit` block, to
    make sure that a stale socket path is removed at program exit, but not
    before.
  * Add corresponding test expectation for `at_exit` invocation

## 2025-07-01 v0.0.0

  * Start
