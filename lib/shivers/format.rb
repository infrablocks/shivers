# frozen_string_literal: true

require_relative 'visitors'

module Shivers
  class Format
    def initialize(formatter)
      @formatter = formatter
    end

    def visit(visitor)
      @formatter.call(visitor)
    end

    def extract_children(parts, captures, children)
      children.reduce(captures) do |captures, child|
        target = captures[child.capture_group]
        first_match = child.first.match(target)

        return captures unless first_match

        first_captures = first_match.named_captures.transform_keys(&:to_sym)
        rest_match = first_captures[:rest].scan(child.rest)
        rest_names = child.rest.names.map(&:to_sym)
        rest_captures = rest_match.reduce({}) do |captures, matches|
          captures.merge(rest_names.zip(matches).to_h) do |name, left, right|
            if parts[name]&.multivalued?
              [left].append(right)
            else
              right
            end
          end
        end
        captures = first_captures.reduce(captures) do |captures, capture|
          name, value = capture
          if parts[name]&.multivalued?
            captures.merge(name => (captures[name] || []).append(value))
          else
            captures.merge(name => value)
          end
        end
        captures = rest_captures.reduce(captures) do |captures, capture|
          name, value = capture
          if parts[name]&.multivalued?
            captures.merge(name => (captures[name] || []).concat(value))
          else
            captures.merge(name => value)
          end
        end

        captures
      end
    end

    def extract(parts, value)
      matcher_visitor = Visitors::MatcherVisitor.new(parts)

      @formatter.call(matcher_visitor)

      result = matcher_visitor.result
      parent_matcher = /\A#{result.parent}\z/

      parent_match = parent_matcher.match(value)

      unless parent_match
        raise(
          ArgumentError,
          "Version string: '#{value}' does not satisfy expected format."
        )
      end

      parent_captures = parent_match.named_captures.transform_keys(&:to_sym)
      total_captures = extract_children(parts, parent_captures, result.children)

      parts
        .select { |_, part| part.capturable? }
        .map { |name, part| [name, part&.convert(total_captures[name])] }
        .to_h
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
