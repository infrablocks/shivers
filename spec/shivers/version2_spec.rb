# frozen_string_literal: true

require 'spec_helper'

describe Shivers::Version2 do
  describe 'equality' do
    it 'is equal to other with identical parts, values and format' do
      formatter = ->(v) { [v.major, v.separator, v.minor] }
      format = Shivers::Format.new(formatter)
      parts = {
        major: Shivers::Parts::Numeric.new,
        minor: Shivers::Parts::Numeric.new,
        separator: Shivers::Parts::Static.new(value: '.')
      }
      values = { major: 2, minor: 1 }

      first = described_class.new(
        parts: parts, values: values, format: format
      )
      second = described_class.new(
        parts: parts, values: values, format: format
      )

      expect(first).to(eql(second))
      expect(first).to(be == second)
    end

    it 'is not equal to other with different parts' do
      formatter = ->(v) { [v.major, v.separator, v.minor] }
      format = Shivers::Format.new(formatter)
      values = { major: 2, minor: 1 }

      first = described_class.new(
        format: format, values: values,
        parts: {
          major: Shivers::Parts::Numeric.new,
          minor: Shivers::Parts::Numeric.new,
          separator: Shivers::Parts::Static.new(value: ';')
        }
      )
      second = described_class.new(
        format: format, values: values,
        parts: {
          major: Shivers::Parts::Numeric.new,
          minor: Shivers::Parts::Numeric.new,
          separator: Shivers::Parts::Static.new(value: '.')
        }
      )

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other with different values' do
      formatter = ->(v) { [v.major, v.separator, v.minor] }
      format = Shivers::Format.new(formatter)
      parts = {
        major: Shivers::Parts::Numeric.new,
        minor: Shivers::Parts::Numeric.new,
        separator: Shivers::Parts::Static.new(value: '.')
      }

      first = described_class.new(
        parts: parts, format: format, values: { major: 2, minor: 1 }
      )
      second = described_class.new(
        parts: parts, format: format, values: { major: 1, minor: 7 }
      )

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other with different format' do
      parts = {
        major: { type: :numeric },
        minor: { type: :numeric },
        separator: { type: :static, value: '.' }
      }
      values = { major: 2, minor: 1 }

      first = described_class.new(
        parts: parts, values: values,
        format: Shivers::Format.new(lambda { |v|
          [v.major, v.optionally { |o| [o.separator, o.minor] }]
        })
      )
      second = described_class.new(
        parts: parts, values: values,
        format: Shivers::Format.new(lambda { |v|
          [v.major, v.separator, v.minor]
        })
      )

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other of different type' do
      formatter = ->(v) { [v.major, v.separator, v.minor] }
      format = Shivers::Format.new(formatter)
      parts = {
        major: Shivers::Parts::Numeric.new,
        minor: Shivers::Parts::Numeric.new,
        separator: Shivers::Parts::Static.new(value: '.')
      }
      values = { major: 3, minor: 2 }

      first = described_class.new(
        parts: parts, values: values, format: format
      )
      second = Class.new(described_class).new(
        parts: parts, values: values, format: format
      )

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'has the same hash if equal' do
      formatter = ->(v) { [v.major, v.separator, v.minor] }
      format = Shivers::Format.new(formatter)
      parts = {
        major: Shivers::Parts::Numeric.new,
        minor: Shivers::Parts::Numeric.new,
        separator: Shivers::Parts::Static.new(value: '.')
      }
      values = { major: 2, minor: 1 }

      first = described_class.new(
        parts: parts, values: values, format: format
      )
      second = described_class.new(
        parts: parts, values: values, format: format
      )

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash if other has different parts' do
      formatter = ->(v) { [v.major, v.separator, v.minor] }
      format = Shivers::Format.new(formatter)
      values = { major: 2, minor: 1 }

      first = described_class.new(
        format: format, values: values,
        parts: {
          major: Shivers::Parts::Numeric.new,
          minor: Shivers::Parts::Numeric.new,
          separator: Shivers::Parts::Static.new(value: ';')
        }
      )
      second = described_class.new(
        format: format, values: values,
        parts: {
          major: Shivers::Parts::Numeric.new,
          minor: Shivers::Parts::Numeric.new,
          separator: Shivers::Parts::Static.new(value: '.')
        }
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different has if other has different values' do
      formatter = ->(v) { [v.major, v.separator, v.minor] }
      format = Shivers::Format.new(formatter)
      parts = {
        major: Shivers::Parts::Numeric.new,
        minor: Shivers::Parts::Numeric.new,
        separator: Shivers::Parts::Static.new(value: '.')
      }

      first = described_class.new(
        parts: parts, format: format, values: { major: 2, minor: 1 }
      )
      second = described_class.new(
        parts: parts, format: format, values: { major: 1, minor: 7 }
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash if other has different format' do
      parts = {
        major: Shivers::Parts::Numeric.new,
        minor: Shivers::Parts::Numeric.new,
        separator: Shivers::Parts::Static.new(value: '.')
      }
      values = { major: 2, minor: 1 }

      first = described_class.new(
        parts: parts, values: values,
        format: Shivers::Format.new(lambda { |v|
          [v.major, v.optional { |o| [o.separator, o.minor] }]
        })
      )
      second = described_class.new(
        parts: parts, values: values,
        format: Shivers::Format.new(lambda { |v|
          [v.major, v.separator, v.minor]
        })
      )

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash if other has different type' do
      formatter = ->(v) { [v.major, v.separator, v.minor] }
      format = Shivers::Format.new(formatter)
      parts = {
        major: Shivers::Parts::Numeric.new,
        minor: Shivers::Parts::Numeric.new,
        separator: Shivers::Parts::Static.new(value: '.')
      }
      values = { major: 1, minor: 2 }

      first = described_class.new(
        parts: parts, values: values, format: format
      )
      second = Class.new(described_class).new(
        parts: parts, values: values, format: format
      )

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
