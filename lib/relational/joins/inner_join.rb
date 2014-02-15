require_relative 'join'

module Relational
  module Joins
    class InnerJoin < Join
      def initialize(table, condition)
        super(table, condition, "INNER")
      end
    end
  end
end
