require_relative 'join'

module Relational
  module Joins
    class LeftJoin < Join
      def initialize(table, condition)
        super(table, condition, "LEFT")
      end
    end
  end
end
