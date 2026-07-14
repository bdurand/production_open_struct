# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.1

### Fixed
- Use `raise` and an explicit block argument instead of the `raise!` and `block_given!` aliases which do not exist in the ostruct versions bundled with Ruby <= 3.0 or on JRuby. Previously on those versions, errors from `delete_field` on a missing field, setter calls with the wrong number of arguments, and undefined method calls with arguments could be silently swallowed instead of raised.
- `respond_to?` no longer raises an error on an allocated but uninitialized OpenStruct.
- `delete_field` now raises a `FrozenError` on frozen objects on ostruct versions that do not freeze the internal table.
- `delete_field` removes stale singleton method accessors from objects created before the gem was loaded.

## 1.0.0

### Added
- Override OpenStuct to not define singleton methods which clear the Ruby method cache.
