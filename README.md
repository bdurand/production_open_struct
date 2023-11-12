# Production OpenStuct

[![Continuous Integration](https://github.com/bdurand/production_open_struct/actions/workflows/continuous_integration.yml/badge.svg)](https://github.com/bdurand/production_open_struct/actions/workflows/continuous_integration.yml)
[![Regression Test](https://github.com/bdurand/production_open_struct/actions/workflows/regression_test.yml/badge.svg)](https://github.com/bdurand/production_open_struct/actions/workflows/regression_test.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Gem Version](https://badge.fury.io/rb/production_open_struct.svg)](https://badge.fury.io/rb/production_open_struct)

This gem overrides behavior in the [OpenStruct](https://github.com/ruby/ostruct) implementation defined in the Ruby standard library. While OpenStruct can be useful for one off scripts or as testing mocks, it can cause performance issues in production environments.

OpenStruct defines singleton methods on every object created for each key in the hash. Defining these methods is slow and it busts the global method cache used by the Ruby VM requiring it to be rebuilt after every OpenStruct object is created.

```ruby
# This defines methods "foo" and "foo=" on object and busts the method cache
object = OpenStruct.new(foo: "bar")
object.foo # => "bar"
object.foo = "biz"
object.foo # => "bix"
```

It is not a good idea to use OpenStruct in your production code. It is much more efficient and safer to just define some simple classes or use `Struct` rather than using OpenStruct. However, not everyone sticks to this and you can end up with external libraries in your application that do use OpenStruct.

This gem solves the OpenStruct performance issues by simply overriding the code in OpenStruct that defines singleton methods. This doesn't have any functional affect on OpenStruct objects; you can still use the attribute reader and writer methods. However, these will now go through `method_missing` every time you call them. This does add its own overhead but it is far more performant in most cases than defining dynamic methods. Furthermore, the global method cache is no longer impacted by creating OpenStruct objects.

## Usage

Nothing is needed to use this gem other than requiring it.

```ruby
require "production_open_struct"
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'production_open_struct'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install production_open_struct
```

## Contributing

Open a pull request on GitHub.

Please use the [standardrb](https://github.com/testdouble/standard) syntax and lint your code with `standardrb --fix` before submitting.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
