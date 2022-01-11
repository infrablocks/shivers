# frozen_string_literal: true

require_relative 'visitors'

module Shivers
  class Format
    def initialize(formatter)
      @formatter = formatter
    end

    def extract(parts, value)
      matcher_visitor = MatcherVisitor.new(parts)
      capture_group_visitor = CaptureGroupVisitor.new(parts)

      @formatter.call(matcher_visitor)
      @formatter.call(capture_group_visitor)

      matcher = matcher_visitor.full_matcher
      capture_groups = capture_group_visitor.capture_groups

      match = matcher.match(value)

      unless match
        raise(
          ArgumentError,
          "Version string: '#{value}' does not satisfy expected format."
        )
      end

      capture_groups
        .transform_values do |group|
          group[:part].convert(match[group[:index]])
        end
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
