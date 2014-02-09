require_relative 'attribute_like'

module Relational
  module Attributes
    class Modifiable < AttributeLike
      def ==(other)
        Equality.new('=', self, other)
      end

      Relational::Adapters.define_function :sum, all: ->(this){
        partial = this.partial
        ["SUM(#{partial.query})", partial.attributes]
      }
    end
  end
end
