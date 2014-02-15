require_relative 'attribute_like'

module Relational
  module Attributes
    class All < AttributeLike
      def self.partial
        PartialStatement.new('*', [])
      end
    end
  end
end
