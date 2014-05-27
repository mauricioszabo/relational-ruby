begin
require 'active_record'
require_relative '../query'

module Relational
  module AR
    class Results
      include Enumerable
      attr_reader :result_set, :model
      protected :result_set, :model

      def initialize(result_set, model)
        @result_set, @model = result_set, model
      end

      def each
        @result_set.each do |row|
          yield map_to(row)
        end
      end

      def ==(other)
        other.class == self.class && result_set.to_a == other.result_set.to_a && model == other.model
      end

      def [](index)
        row = result_set.to_a[index]
        map_to(row) if row
      end

      def size
        result_set.to_a.size
      end

      def map_to(row)
        @model.instantiate(row)
      end
    end
  end
end

rescue LoadError
end
