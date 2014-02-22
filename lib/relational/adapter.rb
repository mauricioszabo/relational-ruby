module Relational
  module Adapter
    extend self

    def current_driver
      @current_driver || 'all'
    end

    def define_driver(driver)
      @current_driver = driver.to_s
    end

    def add_custom_function(function, driver, body)
      @functions ||= {}
      @functions[driver.to_s] ||= {}
      @functions[driver.to_s][function] = body
    end

    def partial_for_function(function, attribute, params)
      functions_for_current = @functions.fetch(current_driver) { {} }
      function =  functions_for_current[function] || @functions['all'][function]
      result = function.call(attribute, *params)
      if result.is_a?(Relational::PartialStatement)
        result
      else
        query, params = result
        Relational::PartialStatement.new(query, params)
      end
    end
  end
end
