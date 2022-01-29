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

    expected_parent_regex =
      /(?<first>0|[1-9]\d*)\.(?<second>0|[1-9]\d*)\.(?<third>[a-zA-Z0-9]+)/

    expect(visitor.result)
      .to(eq(OpenStruct.new(
               {
                 parent: expected_parent_regex,
                 children: []
               }
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

    expected_parent_regex =
      /(?<first>0|[1-9]\d*)(?:\.(?<second>[a-zA-Z0-9]+))?/

    expect(visitor.result)
      .to(eq(OpenStruct.new(
               {
                 parent: expected_parent_regex,
                 children: []
               }
             )))
  end

  it 'produces matchers for parts and format with multiple optional section' do
    formatter = lambda do |v|
      [
        v.first,
        v.optionally { |o| [o.separator_1, o.second] },
        v.optionally { |o| [o.separator_2, o.third] }
      ]
    end
    format = F.new(formatter)
    parts = {
      first: P::Numeric.new,
      second: P::Alphanumeric.new,
      third: P::Alphanumeric.new,
      separator_1: P::Static.new(value: '.'),
      separator_2: P::Static.new(value: '-')
    }

    visitor = Vs::MatcherVisitor.new(parts)

    format.visit(visitor)

    first_part = /(?<first>0|[1-9]\d*)/
    second_part = /(?:\.(?<second>[a-zA-Z0-9]+))?/
    third_part = /(?:\-(?<third>[a-zA-Z0-9]+))?/

    expected_parent_regex =
      /#{first_part.source}#{second_part.source}#{third_part.source}/

    expect(visitor.result)
      .to(eq(OpenStruct.new(
               {
                 parent: expected_parent_regex,
                 children: []
               }
             )))
  end

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

    first_part = /(?<first>0|[1-9]\d*)/
    optional_part =
      /(?:\.(?<second>[a-zA-Z0-9]+)(?:\.(?<third>[a-zA-Z0-9]+))?)?/

    expected_parent_regex =
      /#{first_part.source}#{optional_part.source}/

    expect(visitor.result)
      .to(eq(OpenStruct.new(
        {
               parent: expected_parent_regex,
               children: []
             }
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

    expected_parent_regex =
      /(?<first>0|[1-9]\d*)(?<prerelease>\.[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*)/
    expected_children_regexes =
      [
        OpenStruct.new(
          {
          capture_group: :prerelease,
          first: /\.(?<second>[a-zA-Z0-9]+)(?<rest>(?:\.[a-zA-Z0-9]+)*)?/,
          rest: /\.(?<second>[a-zA-Z0-9]+)/
        }
        )
      ]

    expect(visitor.result)
      .to(eq(OpenStruct.new(
        {
               parent: expected_parent_regex,
               children: expected_children_regexes
             }
          )))
  end
end
