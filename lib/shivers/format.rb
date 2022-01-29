# frozen_string_literal: true

require_relative 'visitors'

module Shivers
  class Format
    def initialize(formatter)
      @formatter = formatter
    end

    def visit(visitor)
      @formatter.call(visitor)
    end

    def ==(other)
      other.class == self.class && other.state == state
    end

    alias eql? ==

    def hash
      self.class.hash ^ state.hash
    end

    def state
      [@formatter]
    end
  end
end
