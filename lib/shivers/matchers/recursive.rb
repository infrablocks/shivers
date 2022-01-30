# frozen_string_literal: true

module Shivers
  module Matchers
    class Recursive
      include ValueEquality

      attr_reader :capture_group, :first, :rest

      def initialize(capture_group, first, rest)
        @capture_group = capture_group
        @first = first
        @rest = rest
      end

      def state
        [@capture_group, @first, @rest]
      end
    end
  end
end
