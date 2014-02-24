require_relative '../partial'

module Relational
  module Orders
    class Ascending
      include Partial
      def initialize(partial)
        @partial = partial.partial
      end

      lazy :partial do
        PartialStatement.new(
          "(#{@partial.query}) ASC",
          @partial.attributes
        )
      end
    end
  end
end
