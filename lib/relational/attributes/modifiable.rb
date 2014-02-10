require_relative 'attribute_like'

module Relational
  module Attributes
    class Modifiable < AttributeLike
      def nil?
        self == nil
      end

      Relational::Adapters.define_function :==, all: ->(this, operand) {
        partial = this.partial
        operand_p = Relational::Attributes.wrap(operand).partial
        ["#{partial.query} = #{operand_p.query}", partial.attributes + operand_p.attributes]
      }

      Relational::Adapters.define_function :!=, all: ->(this, operand) {
        partial = this.partial
        operand_p = Relational::Attributes.wrap(operand).partial
        ["#{partial.query} <> #{operand_p.query}", partial.attributes + operand_p.attributes]
      }

      %w[< <= > >=].each do |operator|
        Relational::Adapters.define_function operator, all: ->(this, operand) {
          partial = this.partial
          operand_p = Relational::Attributes.wrap(operand).partial
          ["#{partial.query} #{operator} #{operand_p.query}", partial.attributes + operand_p.attributes]
        }
      end

      Relational::Adapters.define_function :sum, all: ->(this) {
        partial = this.partial
        ["SUM(#{partial.query})", partial.attributes]
      }

      [:like, :=~].each do |like|
        Relational::Adapters.define_function like, all: ->(this, operand){
          partial = this.partial
          operand_p = Relational::Attributes.wrap(operand).partial
          ["#{partial.query} LIKE #{operand_p.query}", partial.attributes + operand_p.attributes]
        }
      end

      [:not_like, :!~].each do |like|
        Relational::Adapters.define_function like, all: ->(this, operand){
          partial = this.partial
          operand_p = Relational::Attributes.wrap(operand).partial
          ["#{partial.query} NOT LIKE #{operand_p.query}", partial.attributes + operand_p.attributes]
        }
      end
    end
  end
end
