# frozen_string_literal: true

require 'spec_helper'

describe Shivers::Parts::Static do
  describe 'equality' do
    it 'is equal to other with same value' do
      first = described_class.new(value: '.')
      second = described_class.new(value: '.')

      expect(first).to(eql(second))
      expect(first).to(be == second)
    end

    it 'is not equal to other with different value' do
      first = described_class.new(value: '.')
      second = described_class.new(value: '-')

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other of different type' do
      first = described_class.new(value: '.')
      second = Class.new(described_class).new(value: '.')

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'has the same hash if equal' do
      first = described_class.new(value: '.')
      second = described_class.new(value: '.')

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash if other has different value' do
      first = described_class.new(value: '.')
      second = described_class.new(value: '-')

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash if other has different type' do
      first = described_class.new(value: '.')
      second = Class.new(described_class).new(value: '.')

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
