# frozen_string_literal: true

require_relative 'value_equality'

module Shivers
  class Format
    include ValueEquality

    def initialize(formatter)
      @formatter = formatter
    end

    def visit(visitor)
      @formatter.call(visitor)
    end

    def state
      [@formatter]
    end
  end
end
