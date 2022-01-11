# frozen_string_literal: true

module Shivers
  class CaptureGroupVisitor
    attr_reader :capture_groups, :capture_group_index

    def initialize(parts, capture_group_index = 1)
      @parts = parts
      @capture_group_index = capture_group_index
      @capture_groups = {}
    end

    def optionally(&block)
      sub_visitor = CaptureGroupVisitor.new(@parts, @capture_group_index)
      block.call(sub_visitor)
      @capture_groups = @capture_groups.merge(sub_visitor.capture_groups)
      @capture_group_index = sub_visitor.capture_group_index
    end

    def method_missing(symbol, *_args)
      part = @parts[symbol]

      if part.captured?
        @capture_groups[symbol] = {
          index: @capture_group_index,
          part: part
        }
        @capture_group_index += 1
      end
    end
  end
end