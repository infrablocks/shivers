# frozen_string_literal: true

require 'ostruct'
require 'spec_helper'

describe Shivers::Visitors::MatcherVisitor do
  it 'produces matchers for parts and format with nothing optional or ' \
     'recursive' do
    formatter = lambda do |v|
      [v.first, v.separator, v.second, v.separator, v.third]
    end
    format = F.new(formatter)
    parts = {
      first: P::Numeric.new,
      second: P::Numeric.new,
      third: P::Alphanumeric.new,
      separator: P::Static.new(value: '.')
    }

    visitor = Vs::MatcherVisitor.new(parts)

    format.visit(visitor)

    expected_matcher_regexp =
      /0|[1-9]\d*\.0|[1-9]\d*\.[a-zA-Z0-9]+/
    expected_capturer_regexp =
      /(?<first>0|[1-9]\d*)\.(?<second>0|[1-9]\d*)\.(?<third>[a-zA-Z0-9]+)/

    expect(visitor.result)
      .to(eq(M::Parent.new(
               expected_matcher_regexp,
               expected_capturer_regexp,
               []
             )))
  end

  it 'produces matchers for parts and format with single optional section' do
    formatter = lambda do |v|
      [v.first, v.optionally { |o| [o.separator, o.second] }]
    end
    format = F.new(formatter)
    parts = {
      first: P::Numeric.new,
      second: P::Alphanumeric.new,
      separator: P::Static.new(value: '.')
    }

    visitor = Vs::MatcherVisitor.new(parts)

    format.visit(visitor)

    expected_matcher_regexp =
      /0|[1-9]\d*(?:\.[a-zA-Z0-9]+)?/
    expected_capturer_regexp =
      /(?<first>0|[1-9]\d*)(?:\.(?<second>[a-zA-Z0-9]+))?/

    expect(visitor.result)
      .to(eq(M::Parent.new(
               expected_matcher_regexp,
               expected_capturer_regexp,
               []
             )))
  end

  # rubocop:disable Style/RedundantRegexpEscape
  it 'produces matchers for parts and format with multiple optional section' do
    formatter = lambda do |v|
      [
        v.first,
        v.optionally { |o| [o.separator1, o.second] },
        v.optionally { |o| [o.separator2, o.third] }
      ]
    end
    format = F.new(formatter)
    parts = {
      first: P::Numeric.new,
      second: P::Alphanumeric.new,
      third: P::Alphanumeric.new,
      separator1: P::Static.new(value: '.'),
      separator2: P::Static.new(value: '-')
    }

    visitor = Vs::MatcherVisitor.new(parts)

    format.visit(visitor)

    first_capturer = /(?<first>0|[1-9]\d*)/
    second_capturer = /(?:\.(?<second>[a-zA-Z0-9]+))?/
    third_capturer = /(?:\-(?<third>[a-zA-Z0-9]+))?/

    capturers = [first_capturer, second_capturer, third_capturer]

    expected_matcher_regexp = /0|[1-9]\d*(?:\.[a-zA-Z0-9]+)?(?:\-[a-zA-Z0-9]+)?/
    expected_capturer_regexp = /#{capturers.collect(&:source).join}/

    expect(visitor.result)
      .to(eq(M::Parent.new(
               expected_matcher_regexp,
               expected_capturer_regexp,
               []
             )))
  end
  # rubocop:enable Style/RedundantRegexpEscape

  it 'produces matchers for parts and format with nested optional sections' do
    formatter = lambda do |v|
      [v.first, v.optionally do |o1|
        [o1.separator, o1.second, o1.optionally do |o2|
          [o2.separator, o2.third]
        end]
      end]
    end
    format = F.new(formatter)
    parts = {
      first: P::Numeric.new,
      second: P::Alphanumeric.new,
      third: P::Alphanumeric.new,
      separator: P::Static.new(value: '.')
    }

    visitor = Vs::MatcherVisitor.new(parts)

    format.visit(visitor)

    first_capturer = /(?<first>0|[1-9]\d*)/
    optional_capturer =
      /(?:\.(?<second>[a-zA-Z0-9]+)(?:\.(?<third>[a-zA-Z0-9]+))?)?/

    expected_matcher_regexp = /0|[1-9]\d*(?:\.[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)?)?/
    expected_capturer_regexp =
      /#{first_capturer.source}#{optional_capturer.source}/

    expect(visitor.result)
      .to(eq(M::Parent.new(
               expected_matcher_regexp,
               expected_capturer_regexp,
               []
             )))
  end

  it 'produces matchers for parts and format with single recursive section' do
    formatter = lambda do |v|
      [
        v.first,
        v.recursively(:prerelease) do |r|
          r.first { |f| [f.separator, f.second] }
          r.rest { |s| [s.separator, s.second] }
        end
      ]
    end
    format = F.new(formatter)
    parts = {
      first: P::Numeric.new,
      second: P::Alphanumeric.new,
      separator: P::Static.new(value: '.')
    }

    visitor = Vs::MatcherVisitor.new(parts)

    format.visit(visitor)

    expected_matcher_regexp = /0|[1-9]\d*\.[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*/
    expected_capturer_regexp =
      /(?<first>0|[1-9]\d*)(?<prerelease>\.[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*)/
    expected_children_matchers =
      [
        M::Recursive.new(
          :prerelease,
          /\.(?<second>[a-zA-Z0-9]+)(?<rest>(?:\.[a-zA-Z0-9]+)*)?/,
          /\.(?<second>[a-zA-Z0-9]+)/
        )
      ]

    expect(visitor.result)
      .to(eq(M::Parent.new(
               expected_matcher_regexp,
               expected_capturer_regexp,
               expected_children_matchers
             )))
  end
end
