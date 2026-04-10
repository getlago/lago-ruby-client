# Change log

## 0.6.0

* [#59](https://github.com/rubocop/rubocop-thread_safety/pull/59): Rename `ThreadSafety::InstanceVariableInClassMethod` cop to `ThreadSafety::ClassInstanceVariable` to better reflect its purpose. ([@viralpraxis](https://github.com/viralpraxis))
* [#55](https://github.com/rubocop/rubocop-thread_safety/pull/55): Enhance `ThreadSafety::InstanceVariableInClassMethod` cop to detect offenses within `class_eval/exec` blocks. ([@viralpraxis](https://github.com/viralpraxis))
* [#54](https://github.com/rubocop/rubocop-thread_safety/pull/54): Drop support for RuboCop older than 1.48. ([@viralpraxis](https://github.com/viralpraxis))
* [#52](https://github.com/rubocop/rubocop-thread_safety/pull/52): Add new `RackMiddlewareInstanceVariable` cop to detect instance variables in Rack middleware. ([@viralpraxis](https://github.com/viralpraxis))
* [#48](https://github.com/rubocop/rubocop-thread_safety/pull/48): Do not report instance variables in `ActionDispatch` callbacks in singleton methods. ([@viralpraxis](https://github.com/viralpraxis))
* [#43](https://github.com/rubocop/rubocop-thread_safety/pull/43): Make detection of ActiveSupport's `class_attribute` configurable. ([@viralpraxis](https://github.com/viralpraxis))
* [#42](https://github.com/rubocop/rubocop-thread_safety/pull/42): Fix some `InstanceVariableInClassMethod` cop false positive offenses. ([@viralpraxis](https://github.com/viralpraxis))
* [#41](https://github.com/rubocop/rubocop-thread_safety/pull/41): Drop support for MRI older than 2.7. ([@viralpraxis](https://github.com/viralpraxis))
* [#38](https://github.com/rubocop/rubocop-thread_safety/pull/38): Fix `NewThread` cop detection is case of `Thread.start`, `Thread.fork`, or `Thread.new` with arguments. ([@viralpraxis](https://github.com/viralpraxis))
* [#36](https://github.com/rubocop/rubocop-thread_safety/pull/36): Add new `DirChdir` cop to detect `Dir.chdir` calls. ([@viralpraxis](https://github.com/viralpraxis))
