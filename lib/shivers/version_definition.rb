# frozen_string_literal: true

require 'ostruct'

require_relative 'parts'
require_relative 'format'
require_relative 'visitors'
require_relative 'value_equality'

module Shivers
  class VersionDefinition
    PART_TYPES = {
      numeric: Parts::Numeric,
      alphanumeric: Parts::Alphanumeric,
      alphanumeric_or_hyphen: Parts::AlphanumericOrHyphen,
      static: Parts::Static
    }.freeze

    include ValueEquality

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

    def state
      [@parts, @format]
    end
  end
end
