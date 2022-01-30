# frozen_string_literal: true

module Shivers
  module Matchers
    class Child
      include ValueEquality

      attr_reader :matcher, :capturer, :child

      def initialize(matcher, capturer, child)
        @matcher = matcher
        @capturer = capturer
        @child = child
      end

      def state
        [@matcher, @capturer, @child]
      end
    end
  end
end
