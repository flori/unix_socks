# Changes

## 2026-11-18 v0.5.0

### Breaking

- Relaxed the `json` runtime dependency constraint from `~> 2.0` to `>= 2.0`,
  `< 4`.

### Improvements

- Added `json-generic_object` as a runtime dependency to ensure
  `JSON::GenericObject` availability on `json` 3.x.
- Updated `lib/unix_socks/message.rb` to require `json/generic_object` instead
  of `json`.

### Build & CI

- Bumped the `gem_hadar` development dependency requirement to `>= 2.24.1`.
- Removed Vim modeline comments from `Gemfile` and `Rakefile`.

## 2026-04-19 v0.4.0

- Implement secure permissions for Unix sockets using `File.chmod` with a
  default value of `0600` in `UnixSocks::DomainSocketServer#receive`
    - Refactor `UnixSocks::DomainSocketServer#receive` to use new private method
      `loop_for_path` for socket lifecycle management
    - Add guard clause to `UnixSocks::DomainSocketServer#receive` and
      `UnixSocks::TCPSocketServer#receive` to ensure a block is provided
    - Introduce `unix_socket_abstract_name?` method to handle Linux abstract
      namespace sockets
    - Use `IO.select` and `accept_nonblock` in server loop for better
      responsiveness
    - Update `transmit` and `transmit_with_response` to use safe navigation
      `&.close` when closing sockets
- Update gemspec versions and dependencies, including `rubygems_version` from
  **4.0.2** to **4.0.10** and development dependency for `gem_hadar` from **>=
  2.16.0** to **>= 2.17.0**
- Update CI configuration to use stable Ruby **4.0** release instead of release
  candidate

## 2025-12-24 v0.3.0

- Refactored socket server architecture by splitting `UnixSocks::Server` into
  `UnixSocks::DomainSocketServer` and `UnixSocks::TCPSocketServer`
- Added `UnixSocks::ServerShared` module to encapsulate common functionality
  shared between socket server implementations
- Implemented `to_url` method for both server types to generate `unix://path`
  and `tcp://host:port` URLs
- Introduced `UnixSocks::ServerError` marker module for consistent error
  handling across the library
- Updated all documentation and tests to reflect the new dual socket server
  architecture
- Maintained backward compatibility for core communication patterns
- Added comprehensive test coverage for both `UnixSocks::DomainSocketServer`
  and `UnixSocks::TCPSocketServer` implementations
- Added `.rspec` file to configure RSpec with detailed output format (`--format
  d`) for improved test output readability

## 2025-12-23 v0.2.3

- Handle `Errno::ENOENT` errors in the background socket server thread to
  prevent crashes when socket files are removed or become inaccessible
- Add test case to verify background thread execution and `ENOENT` error
  handling
- Maintain existing `at_exit` cleanup behavior to ensure socket file removal
- Update `UnixSocks::DomainSocketServer` to be more resilient to temporary file system
  conditions
- Update `gem_hadar` development dependency to version **2.16.0**

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

- Introduced `UnixSocks::DomainSocketServer.default_runtime_dir` class method
- Simplified coverage configuration by using `GemHadar::SimpleCov.start`

## 2025-07-13 v0.0.1

* Modify server to use `at_exit` for socket cleanup:
  * Replace direct call to `remove_socket_path` with an `at_exit` block, to
    make sure that a stale socket path is removed at program exit, but not
    before.
  * Add corresponding test expectation for `at_exit` invocation

## 2025-07-01 v0.0.0

  * Start
