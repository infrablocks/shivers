# frozen_string_literal: true

require 'spec_helper'

describe Shivers::Format do
  describe 'equality' do
    it 'is equal to other with identical formatter' do
      formatter = ->(v) { [v.whatever] }

      first = described_class.new(formatter)
      second = described_class.new(formatter)

      expect(first).to(eql(second))
      expect(first).to(be == second)
    end

    it 'is not equal to other with different formatter' do
      first = described_class.new(->(v) { [v.whatever] })
      second = described_class.new(->(v) { [v.whatever] })

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other of different type' do
      formatter = ->(v) { [v.whatever] }

      first = described_class.new(formatter)
      second = Class.new(described_class).new(formatter)

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'has the same hash if equal' do
      formatter = ->(v) { [v.whatever] }

      first = described_class.new(formatter)
      second = described_class.new(formatter)

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash if other has different formatter' do
      first = described_class.new(->(v) { [v.whatever] })
      second = described_class.new(->(v) { [v.whatever] })

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash if other has different type' do
      formatter = ->(v) { [v.whatever] }

      first = described_class.new(formatter)
      second = Class.new(described_class).new(formatter)

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
