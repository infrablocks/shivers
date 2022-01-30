# frozen_string_literal: true

require_relative 'value_equality'

module Shivers
  class Version2
    include ValueEquality

    def initialize(data)
      @data = data
    end

    def state
      [@data]
    end
  end
end
