# frozen_string_literal: true

module Shivers
  class Version2
    def initialize(data)
      @data = data
    end

    def ==(other)
      other.class == self.class && other.state == state
    end

    alias eql? ==

    def hash
      self.class.hash ^ state.hash
    end

    def state
      [@data]
    end
  end
end
