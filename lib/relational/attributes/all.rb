require 'singleton'
require_relative 'attribute_like'

module Relational
  module Attributes
    class AllClass < AttributeLike
      extend Adapter::FunctionDefinition
      include Singleton

      def partial
        PartialStatement.new('*', [])
      end

      define_function1 :count
      define_function1 :count_distinct, "COUNT(DISTINCT $1)"
    end

    All = AllClass.instance
  end
end
