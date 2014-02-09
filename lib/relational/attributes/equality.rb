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
        if(@comparable.nil?)
          handle_nil
        else
          PartialStatement.new(query, @attribute.partial.attributes + [@comparable])
        end
      end
    end
  end
end
