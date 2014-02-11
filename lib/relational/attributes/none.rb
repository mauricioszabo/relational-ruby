require_relative "modifiable"
require "singleton"

module Relational
  module Attributes
    class NoneClass < AttributeLike
      include Singleton

      def |(operand)
        operand
      end
      alias :& :|
    end
    None = NoneClass.instance
  end
end
