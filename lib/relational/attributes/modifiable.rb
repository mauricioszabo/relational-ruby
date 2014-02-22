require_relative 'attribute_like'
require_relative 'none'
require_relative '../adapter/function_definition'

module Relational
  module Attributes
    class Modifiable < AttributeLike
      extend Adapter::FunctionDefinition

      def nil?
        self == nil
      end

      in_clause = ->(this, operand) do
        partial = this.partial
        operand_p = Relational::Partial.wrap(operand).partial
        Relational::PartialStatement.new(
          "#{partial.query} IN (#{operand_p.query})",
          partial.attributes + operand_p.attributes
        )
      end

      define_custom_method :in?, all: ->(params) {
        Relational::Comparissions::In.new(self, params)
      }, oracle: ->(params) {
        ins = params.each_slice(1000).map do |slice|
          Relational::Comparissions::In.new(self, slice)
        end
        Relational::Comparissions::Or.new(ins)
      }

      define_custom_method :not_in?, all: ->(params) {
        Relational::Comparissions::In.new(self, params, true)
      }, oracle: ->(params) {
        ins = params.each_slice(1000).map do |slice|
          Relational::Comparissions::In.new(self, slice, true)
        end
        Relational::Comparissions::And.new(ins)
      }

      def ===(other)
        case other
          when NilClass then self.null?
          when Array then self.in?(other)
          else self == other
        end
      end

      define_function2 :==, '$1 = $2'
      define_function2 :!=, '$1 <> $2'
      define_function2 :<, '$1 < $2'
      define_function2 :>, '$1 > $2'
      define_function2 :<=, '$1 <= $2'
      define_function2 :>=, '$1 >= $2'
      define_function2 :=~, '$1 LIKE $2'
      define_function2 :like, '$1 LIKE $2'
      define_function2 :!~, '$1 NOT LIKE $2'
      define_function2 :not_like, '$1 NOT LIKE $2'

      define_function1 :null?, "$1 IS NULL"
      define_function1 :not_null?, "$1 IS NOT NULL"
      define_function1 :!, "NOT($1)"

      define_custom_method :|, all: ->(*items) {
        Relational::Comparissions::Or.new([self, *items])
      }

      define_custom_method :&, all: ->(*items) {
        Relational::Comparissions::And.new([self, *items])
      }

      define_function1 :sum
      define_function1 :avg
      define_function1 :max
      define_function1 :min
      define_function1 :count
      define_function1 :count_distinct, "COUNT(DISTINCT $1)"

      define_function1 :length
      define_function1 :upper
      define_function1 :lower
    end
  end
end
