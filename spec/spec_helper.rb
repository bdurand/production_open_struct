# frozen_string_literal: true

ENV["PRODUCTION_OPEN_STRUCT_AUTO_INCLUDE"] = "false"

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

begin
  require "simplecov"
  SimpleCov.start do
    add_filter ["/spec/"]
  end
rescue LoadError
end

Bundler.require(:default, :test)

require_relative "../lib/production_open_struct"

RSpec.configure do |config|
  config.warnings = true
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?
  # The suite must run in defined order: the "without ProductionOpenStruct"
  # groups run first, then an after(:all) hook prepends the module (which
  # cannot be undone) so the "with" groups test the patched behavior.
  config.order = :defined
end
