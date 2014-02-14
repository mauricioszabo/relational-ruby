require_relative "modifiable"
module Relational
  module Attributes
    class Function < Modifiable
      extend Lazy

      def initialize(function, attribute, params)
        @function, @attribute, @params = function, attribute, params
      end

      lazy :partial do
        Relational::Adapter.partial_for_function(@function, @attribute, @params)
      end
    end
  end
end

