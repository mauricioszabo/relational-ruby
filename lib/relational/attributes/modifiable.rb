require_relative 'attribute_like'
require_relative 'none'
require_relative '../adapter'

module Relational
  module Attributes
    class Modifiable < AttributeLike
      def nil?
        self == nil
      end

      def self.define_function(function, string = "#{function.to_s.upcase}($1)")
        Relational::Adapter.define_function function, all: ->(this) {
          partial = this.partial
          query = string.sub('$1', partial.query)
          [query, partial.attributes]
        }
      end

      def self.define_function2(function, string)
        Relational::Adapter.define_function function, all: ->(this, operand) {
          partial = this.partial
          operand_p = Relational::Partial.wrap(operand).partial
          query = string.sub('$1', partial.query).sub('$2', operand_p.query)
          [query, partial.attributes + operand_p.attributes]
        }
      end

      in_clause = ->(this, operand) do
        partial = this.partial
        operand_p = Relational::Partial.wrap(operand).partial
        Relational::PartialStatement.new(
          "#{partial.query} IN (#{operand_p.query})",
          partial.attributes + operand_p.attributes
        )
      end

      Relational::Adapter.define_custom_method :in?, all: ->(params) {
        Relational::Comparissions::In.new(self, params)
      }, oracle: ->(params) {
        ins = params.each_slice(1000).map do |slice|
          Relational::Comparissions::In.new(self, slice)
        end
        Relational::Comparissions::Or.new(ins)
      }

      Relational::Adapter.define_custom_method :not_in?, all: ->(params) {
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

      define_function :null?, "$1 IS NULL"
      define_function :not_null?, "$1 IS NOT NULL"
      define_function :!, "NOT($1)"

      Relational::Adapter.define_custom_method :|, all: ->(*items) {
        Relational::Comparissions::Or.new([self, *items])
      }

      Relational::Adapter.define_custom_method :&, all: ->(*items) {
        Relational::Comparissions::And.new([self, *items])
      }

      define_function :sum
      define_function :avg
      define_function :max
      define_function :min
      define_function :count
      define_function :count_distinct, "COUNT(DISTINCT $1)"

      define_function :length
      define_function :upper
      define_function :lower
    end
  end
end
