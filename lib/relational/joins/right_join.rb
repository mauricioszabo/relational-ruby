require_relative 'join'

module Relational
  module Joins
    class RightJoin < Join
      def initialize(table, condition)
        super(table, condition, "RIGHT")
      end
    end
  end
end
