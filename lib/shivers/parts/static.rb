# frozen_string_literal: true

require_relative '../value_equality'

module Shivers
  module Parts
    class Static
      include ValueEquality

      def initialize(data)
        @value = data[:value]
      end

      def matcher
        /#{Regexp.quote(@value)}/
      end

      def convert(value)
        value
      end

      def merge(_, second)
        second
      end

      def capturable?
        false
      end

      def multivalued?
        false
      end

      def state
        [@value]
      end
    end
  end
end
