# frozen_string_literal: true

module Shivers
  class MatcherVisitor
    def initialize(parts)
      @parts = parts
      @matchers = []
    end

    def optionally(&block)
      sub_visitor = MatcherVisitor.new(@parts)
      block.call(sub_visitor)
      @matchers << /(?:#{sub_visitor.partial_matcher})?/
    end

    def method_missing(symbol, *_args)
      @matchers << @parts[symbol].matcher
    end

    def partial_matcher
      /#{@matchers.collect(&:source).join}/
    end

    def full_matcher
      /\A#{partial_matcher.source}\z/
    end
  end
end