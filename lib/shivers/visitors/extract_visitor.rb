# frozen_string_literal: true

require 'ostruct'

module Shivers
  module Visitors
    class ExtractVisitor
      def initialize(parts, value, _options = {})
        @parts = parts
        @value = value
        @delegate = MatcherVisitor.new(parts)
      end

      def optionally(&)
        @delegate.optionally(&)
      end

      def recursively(name, &)
        @delegate.recursively(name, &)
      end

      def method_missing(symbol, ...)
        @delegate.send(symbol, ...)
      end

      def respond_to_missing?(symbol, include_private = false)
        @delegate.respond_to_missing?(symbol, include_private) || super
      end

      def result
        matchers = @delegate.result

        parent_captures = match_parent(matchers)
        total_captures = match_children(matchers, parent_captures)

        convert_values(total_captures)
      end

      private

      def match_parent(matchers)
        standard_captures(/\A#{matchers.capturer.source}\z/, @value)
      end

      def match_children(matchers, captures)
        matchers.children.reduce(captures) do |caps, child|
          value = caps[child.capture_group]
          first_captures = standard_captures(child.first, value)

          next caps unless first_captures

          rest_captures = recursive_captures(first_captures[:rest], child.rest)

          caps = merge_captures(caps, first_captures)
          caps = merge_captures(caps, rest_captures)

          caps
        end
      end

      def recursive_captures(value, matcher)
        match_recursively(value, matcher)
          .reduce({}) do |all_rest_captures, rest_captures|
          all_rest_captures.merge(rest_captures) do |name, existing, new|
            merge_capture_value(name, existing, new)
          end
        end
      end

      def match_recursively(value, matcher)
        rest_matches = value.scan(matcher)
        rest_capture_names = matcher.names.map(&:to_sym)
        rest_matches.map do |rest_match|
          rest_capture_names.zip(rest_match).to_h
        end
      end

      def merge_captures(existing, new)
        new.reduce(existing) do |captures, capture|
          name, value = capture
          captures.merge(
            name =>
              merge_capture_value(name, captures[name], value)
          )
        end
      end

      def merge_capture_value(name, existing, new)
        @parts[name]&.merge(existing, new)
      end

      def standard_captures(matcher, value)
        return unless value

        ensure_match(matcher.match(value))
          .named_captures
          .transform_keys(&:to_sym)
      end

      def convert_values(captures)
        capturable_parts
          .to_h { |name, part| [name, part&.convert(captures[name])] }
      end

      def ensure_match(match)
        unless match
          raise(
            ArgumentError,
            "Version string: '#{@value}' does not satisfy expected format."
          )
        end

        match
      end

      def capturable_parts
        @parts.select { |_, part| part.capturable? }
      end
    end
  end
end
