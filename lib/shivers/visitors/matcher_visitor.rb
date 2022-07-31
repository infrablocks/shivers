# frozen_string_literal: true

require 'ostruct'

require_relative '../matchers'
require_relative '../value_equality'

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
          first = visit(@first_block, MatcherVisitor.new(@parts))
          rest = visit(@rest_block, MatcherVisitor.new(@parts))

          Matchers::Child.new(
            parent_matcher(first, rest), parent_capturer(first, rest),
            Matchers::Recursive.new(
              @name, first_capturer(first, rest), rest_capturer(first, rest)
            )
          )
        end

        private

        def visit(block, visitor)
          block.call(visitor)
          visitor.result
        end

        def parent_matcher(first, rest)
          /#{first.matcher.source}(?:#{rest.matcher.source})*/
        end

        def parent_capturer(first, rest)
          /(?<#{@name}>#{first.matcher.source}(?:#{rest.matcher.source})*)/
        end

        def first_capturer(first, rest)
          /#{first.capturer.source}(?<rest>(?:#{rest.matcher.source})*)?/
        end

        def rest_capturer(_, rest)
          /#{rest.capturer.source}/
        end
      end

      def initialize(parts)
        @parts = parts
        @matching_regexps = []
        @capturing_regexps = []
        @children = []
      end

      def optionally(&block)
        sub_visitor = MatcherVisitor.new(@parts)
        block.call(sub_visitor)
        result = sub_visitor.result
        @matching_regexps << /(?:#{result.matcher.source})?/
        @capturing_regexps << /(?:#{result.capturer.source})?/
        @children.concat(result.children)
      end

      def recursively(name, &block)
        sub_visitor = RecursiveMatcherVisitor.new(name, @parts)
        block.call(sub_visitor)
        result = sub_visitor.result
        @matching_regexps << result.matcher
        @capturing_regexps << result.capturer
        @children << result.child
      end

      def method_missing(symbol, *_)
        raise no_dsl_element_error(symbol) unless respond_to_missing?(symbol)

        part = @parts[symbol]

        @matching_regexps << part.matcher
        @capturing_regexps << if part.capturable?
                                /(?<#{symbol}>#{part.matcher.source})/
                              else
                                part.matcher
                              end
      end

      def respond_to_missing?(symbol, _ = false)
        @parts.include?(symbol) || super
      end

      def result
        Matchers::Parent.new(
          /#{@matching_regexps.collect(&:source).join}/,
          /#{@capturing_regexps.collect(&:source).join}/,
          @children
        )
      end

      private

      def no_dsl_element_error(symbol)
        NoMethodError.new(
          "DSL does not include an element with name: '#{symbol}'. " \
          'Check usage.',
          symbol
        )
      end
    end
  end
end
