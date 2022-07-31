# frozen_string_literal: true

module Shivers
  module ValueEquality
    def ==(other)
      other.class == self.class && other.state == state
    end

    alias eql? ==

    def hash
      [self.class, state].hash
    end
  end
end
