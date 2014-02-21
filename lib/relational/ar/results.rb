begin
require 'active_record'
require_relative '../query'

module Relational
  module AR
    class Results
      include Enumerable
      attr_reader :rows, :model
      protected :rows, :model

      def initialize(rows, model)
        @rows, @model = rows, model
      end

      def each
        @rows.each do |row|
          yield map_to(row)
        end
      end

      def ==(other)
        rows == other.rows && model == other.model
      end

      def [](index)
        map_to(@rows[index])
      end

      def map_to(row)
        @model.instantiate(row)
      end
    end
  end
end

rescue LoadError
end
