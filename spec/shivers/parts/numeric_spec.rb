# frozen_string_literal: true

require 'spec_helper'

describe Shivers::Parts::Numeric do
  context 'equality' do
    it 'is equal to other of same type' do
      first = described_class.new
      second = described_class.new

      expect(first).to(eql(second))
      expect(first).to(be == second)
    end

    it 'is not equal to other of different type' do
      first = described_class.new
      second = Class.new(described_class).new

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'has the same hash if equal' do
      first = described_class.new
      second = described_class.new

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash if other has different type' do
      first = described_class.new
      second = Class.new(described_class).new

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
