# frozen_string_literal: true

require 'ostruct'

require_relative 'parts'
require_relative 'format'
require_relative 'visitors'

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
        .transform_values { |part| PART_TYPES[part[:type]].new(part) }
      @format = Format.new(definition[:formatter])
    end

    def parse(value)
      extract_visitor = Visitors::ExtractVisitor.new(@parts, value)

      @format.visit(extract_visitor)

      Version2.new(
        parts: @parts, format: @format,
        values: extract_visitor.result
      )
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
