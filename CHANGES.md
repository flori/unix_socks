# Changes

## 2025-07-13 v0.0.1

* Modify server to use `at_exit` for socket cleanup:
  * Replace direct call to `remove_socket_path` with an `at_exit` block, to
    make sure that a stale socket path is removed at program exit, but not
    before.
  * Add corresponding test expectation for `at_exit` invocation

## 2025-07-01 v0.0.0

  * Start
