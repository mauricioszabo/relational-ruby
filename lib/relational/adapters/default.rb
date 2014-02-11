require_relative '../adapters'

module Relational
  module Adapters
    module Default

      def partial_for_function(function, attribute, params)
        function = send("function_for_#{function}", attribute, *params)
        if function.is_a?(Relational::PartialStatement)
          function
        else
          query, params = function
          Relational::PartialStatement.new(query, params)
        end
      end

      def add_function(name, body)
        self.class.send(:define_method, "function_for_#{name}", &body)
      end

      extend self
    end
  end
end
