module Relational
  module Adapter
    extend self

    def current_driver
      @current_driver || 'all'
    end

    def define_driver(driver)
      @current_driver = driver.to_s
    end

    # define_function defines a function in SQL. For instance, you can define
    # a function that compares something diferently for Postgresql, MySQL
    # and other databases just by using the following command:
    #
    # Relational::Adapters.define_function :compare,
    #   all: proc { |me, p| ["COMPARE(?, ?) == 0", [me, pg]] }
    #   postgresql: proc { |me, p| ["COMPARE_PG(?, ?) == 0", [p1, p2]] }
    #   mysql: proc { |me, p| ["CMP_MYSQL(?, ?) != 0", [p1, p2]] }
    def define_function(function, functions_for_drivers)
      @functions ||= {}
      number_of_params = 0

      functions_for_drivers.each do |driver, body|
        @functions[driver.to_s] ||= {}
        @functions[driver.to_s][function] = body
        number_of_params = body.arity - 1
      end

      Relational::Attributes::Modifiable.send(:define_method, function) do |*params|
        if(number_of_params < 0)
          required_params = number_of_params.abs - 1
          if params.size < required_params
            raise ArgumentError, "wrong number of arguments (#{params.size} for #{required_params}+)"
          end
        else
          if params.size != number_of_params
            raise ArgumentError, "wrong number of arguments (#{params.size} for #{number_of_params})"
          end
        end

        Relational::Attributes::Function.new(function, self, params)
      end
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

    def define_custom_method(method, methods_for_drivers)
      @methods ||= {}
      number_of_params = 0

      methods_for_drivers.each do |driver, body|
        @methods[driver.to_s] ||= {}
        @methods[driver.to_s][method] = body
        number_of_params = body.arity
      end

      at_methods = @methods
      current_driver = -> { current_driver() }

      Relational::Attributes::Modifiable.send(:define_method, method) do |*params|
        if(number_of_params < 0)
          required_params = number_of_params.abs - 1
          if params.size < required_params
            raise ArgumentError, "wrong number of arguments (#{params.size} for #{required_params}+)"
          end
        else
          if params.size != number_of_params
            raise ArgumentError, "wrong number of arguments (#{params.size} for #{number_of_params})"
          end
        end

        methods_for_current = at_methods.fetch(current_driver.call) { {} }
        method_block =  methods_for_current[method] || at_methods['all'][method]
        instance_exec(*params, &method_block)
      end
    end
  end
end
