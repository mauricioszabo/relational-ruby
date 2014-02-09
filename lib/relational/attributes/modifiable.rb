require_relative 'attribute_like'

module Relational
  module Attributes
    class Modifiable < AttributeLike
      def nil?
        self == nil
      end

      def ==(other)
        Equality.new('=', self, other)
      end

      def !=(other)
        Equality.new('<>', self, other)
      end

      %w[< <= > >=].each do |operator|
        define_method operator do |operand|
          Equality.new(operator, self, operand)
        end
      end

      Relational::Adapters.define_function :sum, all: ->(this){
        partial = this.partial
        ["SUM(#{partial.query})", partial.attributes]
      }
    end
  end
end
