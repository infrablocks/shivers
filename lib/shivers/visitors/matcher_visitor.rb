# frozen_string_literal: true
require 'ostruct'

module Shivers
  module Visitors
    class MatcherVisitor
      class RecursiveMatcherVisitor
        def initialize(name, parts)
          @name = name
          @parts = parts
        end

        def first(&block)
          @first_block = block
        end

        def rest(&block)
          @rest_block = block
        end

        def result
          first_matching_sub_visitor =
            MatcherVisitor.new(@parts, capture: false)
          first_capturing_sub_visitor =
            MatcherVisitor.new(@parts, capture: true)
          rest_matching_sub_visitor =
            MatcherVisitor.new(@parts, capture: false)
          rest_capturing_sub_visitor =
            MatcherVisitor.new(@parts, capture: true)

          @first_block.call(first_matching_sub_visitor)
          @first_block.call(first_capturing_sub_visitor)
          @rest_block.call(rest_matching_sub_visitor)
          @rest_block.call(rest_capturing_sub_visitor)

          first_matching_pattern = first_matching_sub_visitor.result.parent.source
          first_capturing_pattern = first_capturing_sub_visitor.result.parent.source
          rest_matching_pattern = rest_matching_sub_visitor.result.parent.source
          rest_capturing_pattern = rest_capturing_sub_visitor.result.parent.source

          matcher = /#{first_matching_pattern}(?:#{rest_matching_pattern})*/
          first = /#{first_capturing_pattern}(?<rest>(?:#{rest_matching_pattern})*)?/
          rest = /#{rest_capturing_pattern}/

          OpenStruct.new(
            {
              parent: matcher,
              child: OpenStruct.new(
                {
                  capture_group: @name,
                  first: first,
                  rest: rest
                }
              )
            }
          )
        end
      end

      def initialize(parts, options = {})
        @parts = parts
        @capture = options.include?(:capture) ? options[:capture] : true
        @matchers = []
        @children = []
      end

      def optionally(&block)
        sub_visitor = MatcherVisitor.new(@parts, capture: @capture)
        block.call(sub_visitor)
        @matchers << /(?:#{sub_visitor.result.parent.source})?/
        @children.concat(sub_visitor.result.children)
      end

      def recursively(name, &block)
        sub_visitor = RecursiveMatcherVisitor.new(name, @parts)
        block.call(sub_visitor)
        result = sub_visitor.result
        parent = result.parent
        parent = @capture ? /(?<#{name}>#{parent.source})/ : /#{parent.source}/
        @matchers << parent
        @children << result.child
      end

      def method_missing(symbol, *_)
        part = @parts[symbol]
        matcher = part.matcher
        matcher = /(?<#{symbol}>#{matcher.source})/ if part.capturable? && @capture
        @matchers << matcher
      end

      def respond_to_missing?(symbol, _ = false)
        @parts.include?(symbol) || super
      end

      def result
        OpenStruct.new(
          {
            parent: /#{@matchers.collect(&:source).join}/,
            children: @children
          }
        )
      end
    end
  end
end