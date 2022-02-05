# frozen_string_literal: true

module Shivers
  module Parts
    module Mixins
      module Multivaluable
        def multivalued?
          @traits.include?(:multivalued)
        end

        def merge(first, second)
          multivalued? ? concatable(first).concat(concatable(second)) : second
        end

        private

        def concatable(value)
          if value.nil?
            []
          elsif value.is_a?(Array)
            value
          else
            [value]
          end
        end
      end
    end
  end
end
