# frozen_string_literal: true

require 'pp'
require 'fileutils'

require 'fakefs/spec_helpers'

require 'bundler/setup'
require 'shivers'

P = Shivers::Parts
F = Shivers::Format
V = Shivers::Version2
Vs = Shivers::Visitors

RSpec.configure do |config|
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
