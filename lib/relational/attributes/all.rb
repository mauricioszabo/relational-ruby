require 'singleton'
require_relative 'attribute_like'

module Relational
  module Attributes
    class AllClass < AttributeLike
      include Singleton

      def partial
        PartialStatement.new('*', [])
      end
    end

    All = AllClass.instance
  end
end
