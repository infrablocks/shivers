# frozen_string_literal: true

require 'spec_helper'

describe Shivers::Format do
  context 'equality' do
    it 'is equal to other with identical formatter' do
      formatter = ->(v) { [v.whatever] }

      first = Shivers::Format.new(formatter)
      second = Shivers::Format.new(formatter)

      expect(first).to(eql(second))
      expect(first).to(be == second)
    end

    it 'is not equal to other with different formatter' do
      first = Shivers::Format.new(->(v) { [v.whatever] })
      second = Shivers::Format.new(->(v) { [v.whatever] })

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'is not equal to other of different type' do
      formatter = ->(v) { [v.whatever] }

      first = Shivers::Format.new(formatter)
      second = Class.new(Shivers::Format).new(formatter)

      expect(first).not_to(eql(second))
      expect(first).not_to(be == second)
    end

    it 'has the same hash if equal' do
      formatter = ->(v) { [v.whatever] }

      first = Shivers::Format.new(formatter)
      second = Shivers::Format.new(formatter)

      expect(first.hash).to(eq(second.hash))
    end

    it 'has different hash if other has different formatter' do
      first = Shivers::Format.new(->(v) { [v.whatever] })
      second = Shivers::Format.new(->(v) { [v.whatever] })

      expect(first.hash).not_to(eq(second.hash))
    end

    it 'has different hash if other has different type' do
      formatter = ->(v) { [v.whatever] }

      first = Shivers::Format.new(formatter)
      second = Class.new(Shivers::Format).new(formatter)

      expect(first.hash).not_to(eq(second.hash))
    end
  end
end
