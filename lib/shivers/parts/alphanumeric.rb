# frozen_string_literal: true

require_relative 'mixins/multivaluable'
require_relative '../value_equality'

module Shivers
  module Parts
    class Alphanumeric
      include ValueEquality
      include Mixins::Multivaluable

      def initialize(data = {})
        @traits = data[:traits] || []
      end

      def matcher
        /[a-zA-Z0-9]+/
      end

      def convert(value)
        value
      end

      def capturable?
        true
      end

      def ==(other)
        other.class == self.class && other.state == state
      end

      alias eql? ==

      def hash
        [self.class, state].hash
      end

      def state
        [@traits]
      end
    end
  end
end
