# frozen_string_literal: true

require 'spec_helper'

describe Shivers::Parts::Static do
  context 'equality' do
    it 'is equal to other with same value' do
      first = Shivers::Parts::Static.new(value: '.')
      second = Shivers::Parts::Static.new(value: '.')

      expect(first).to(eql(second))
      expect(first).to(be == second)
    end

    it 'is not equal to other with different value' do
      first = Shivers::Parts::Static.new(value: '.')
      second = Shivers::Parts::Static.new(value: '-')

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other of different type' do
      first = Shivers::Parts::Static.new(value: '.')
      second = Class.new(Shivers::Parts::Static).new(value: '.')

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'has the same hash if equal' do
      first = Shivers::Parts::Static.new(value: '.')
      second = Shivers::Parts::Static.new(value: '.')

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash if other has different value' do
      first = Shivers::Parts::Static.new(value: '.')
      second = Shivers::Parts::Static.new(value: '-')

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash if other has different type' do
      first = Shivers::Parts::Static.new(value: '.')
      second = Class.new(Shivers::Parts::Static).new(value: '.')

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
