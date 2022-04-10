# frozen_string_literal: true

require_relative 'mixins/multivaluable'
require_relative '../value_equality'

module Shivers
  module Parts
    class Numeric
      include ValueEquality
      include Mixins::Multivaluable

      # rubocop:disable Style/RedundantInitialize
      def initialize(_ = {}); end
      # rubocop:enable Style/RedundantInitialize

      def matcher
        /0|[1-9]\d*/
      end

      def convert(value)
        value&.to_i
      end

      def capturable?
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
