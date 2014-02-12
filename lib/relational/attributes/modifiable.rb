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
          operand_p = Relational::Attributes.wrap(operand).partial
          query = string.sub('$1', partial.query).sub('$2', operand_p.query)
          [query, partial.attributes + operand_p.attributes]
        }
      end

      in_clause = ->(this, operand) do
        partial = this.partial
        operand_p = Relational::Attributes.wrap(operand).partial
        Relational::PartialStatement.new(
          "#{partial.query} IN (#{operand_p.query})",
          partial.attributes + operand_p.attributes
        )
      end

      #Relational::Adapter.define_function :in?,
      #  all: in_clause,
      #  oracle: ->(this, operand) {
      #    partial = this.partial
      #    queries = []
      #    attributes = partial.attributes
      #    operand.each_slice(1000) do |slice|
      #      operand_p = Relational::Attributes.wrap(slice).partial
      #      attributes += operand_p.attributes
      #      queries << "#{partial.query} IN (#{operand_p.query})"
      #    end
      #    ["(#{queries.join(" OR ")})", attributes]
      #}

      Relational::Adapter.define_custom_method :in?,
        all: ->(params) { Relational::Comparissions::In.new(self, params) }

      Relational::Adapter.define_function :not_in?, all: ->(this, operand) {
        partial = this.partial
        operand_p = Relational::Attributes.wrap(operand).partial
        ["#{partial.query} NOT IN (#{operand_p.query})", partial.attributes + operand_p.attributes]
      }

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

      define_function2 :|, "$1 OR $2"
      define_function2 :&, "$1 AND $2"

      define_function :sum
      define_function :avg
      define_function :max
      define_function :min
      define_function :count
    end
  end
end
