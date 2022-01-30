# frozen_string_literal: true

module Shivers
  module Matchers
    class Parent
      include ValueEquality

      attr_reader :matcher, :capturer, :children

      def initialize(matcher, capturer, children)
        @matcher = matcher
        @capturer = capturer
        @children = children
      end

      def state
        [@matcher, @capturer, @children]
      end
    end
  end
end
