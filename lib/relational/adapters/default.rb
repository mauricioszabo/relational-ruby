require_relative '../adapters'

module Relational
  module Adapters
    module Default

      def partial_for_function(function, attribute, params)
        function = get_function(function).call(attribute, *params)
        if function.is_a?(Relational::PartialStatement)
          function
        else
          query, params = function
          Relational::PartialStatement.new(query, params)
        end
      end

      def add_function(name, body)
        @functions ||= {}
        @functions[name] = body
      end

      def get_function(function)
        @functions ||= {}
        if self == Default
          @functions.fetch(function)
        else
          @functions.fetch(function) { Relational::Adapters::Default.get_function(function) }
        end
      end

      extend self
    end

    register_driver('default', Default)
  end
end
