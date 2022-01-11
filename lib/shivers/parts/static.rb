module Shivers
  module Parts
    class Static
      def initialize(data)
        @value = data[:value]
      end

      def matcher
        Regexp.new(Regexp.escape(@value))
      end

      def convert(value)
        value
      end

      def captured?
        false
      end

      def ==(other)
        other.class == self.class && other.state == state
      end

      alias eql? ==

      def hash
        self.class.hash ^ state.hash
      end

      def state
        [@value]
      end
    end
  end
end
