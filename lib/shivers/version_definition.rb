# frozen_string_literal: true

require 'ostruct'

require_relative 'parts'
require_relative 'format'

module Shivers
  class VersionDefinition
    PART_TYPES = {
      numeric: Parts::Numeric,
      alphanumeric: Parts::Alphanumeric,
      static: Parts::Static
    }.freeze

    attr_reader :parts, :format

    def initialize(definition)
      @parts =
        definition[:parts]
        .map { |name, part| [name, PART_TYPES[part[:type]].new(part)] }
        .to_h
      @format = Format.new(definition[:formatter])
    end

    def parse(value)
      Version2.new(
        parts: @parts, format: @format,
        values: @format.extract(@parts, value))
    end

    def ==(other)
      other.class == self.class && other.state == state
    end

    alias eql? ==

    def hash
      self.class.hash ^ state.hash
    end

    def state
      [@parts, @format]
    end
  end
end
