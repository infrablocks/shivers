# frozen_string_literal: true

module Shivers
  module Parts
    class Numeric
      def initialize(_ = {}); end

      def matcher
        /(0|[1-9]\d*)/
      end

      def convert(value)
        value&.to_i
      end

      def captured?
        true
      end

      def ==(other)
        other.class == self.class && other.state == state
      end

      alias eql? ==

      def hash
        self.class.hash ^ state.hash
      end

      def state
        []
      end
    end
  end
end
