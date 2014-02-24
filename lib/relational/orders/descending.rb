require_relative '../partial'

module Relational
  module Orders
    class Descending
      include Partial
      def initialize(partial)
        @partial = partial.partial
      end

      lazy :partial do
        PartialStatement.new(
          "(#{@partial.query}) DESC",
          @partial.attributes
        )
      end
    end
  end
end
