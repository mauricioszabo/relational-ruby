module Relational
  module Adapters
    module Default
      @functions = {}

      def partial_for_function(function, attribute, params)
        query, params = @functions[function].call(attribute, *params)
        Relational::PartialStatement.new(query, params)
      end

      def add_function(name, body)
        @functions[name] = body
      end

      extend self
    end
  end
end
