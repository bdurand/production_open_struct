# frozen_string_literal: true

ENV["PRODUCTION_OPEN_STRUCT_AUTO_INCLUDE"] = "false"

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

require_relative "../lib/production_open_struct"

begin
  require "simplecov"
  SimpleCov.start do
    add_filter ["/spec/"]
  end
rescue LoadError
end

RSpec.configure do |config|
  config.warnings = true
  config.order = :random
end
