require_relative "modifiable"

module Relational
  module Attributes
    class Equality < Modifiable
      extend Lazy

      def initialize(comparission, attribute, comparable)
        @comparission, @attribute, @comparable = comparission, attribute, comparable
      end

      def query
        "#{@attribute.partial.query} #@comparission ?"
      end
      private :query

      lazy(:partial) do
        if(@comparable.nil? && ['=', '<>'].include?(@comparission))
          handle_nil
        else
          PartialStatement.new(query, @attribute.partial.attributes + [@comparable])
        end
      end

      def handle_nil
        query = if(@comparission == "=")
          "IS NULL"
        else
          "IS NOT NULL"
        end
        PartialStatement.new("#{@attribute.partial.query} #{query}", @attribute.partial.attributes)
      end
      private :handle_nil
    end
  end
end
