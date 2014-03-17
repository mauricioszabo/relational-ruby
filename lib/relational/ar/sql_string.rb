require_relative '../partial'

module Relational
  module AR
    class SQLString < Relational::Attributes::Modifiable
      include Partial

      def initialize(string)
        @string = string
      end

      lazy(:partial) { PartialStatement.new(@string, []) }
    end
  end
end
