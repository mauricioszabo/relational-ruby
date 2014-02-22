require_relative '../adapter'

module Relational
  module Adapter
    module FunctionDefinition
      def define_function1(function, string = "#{function.to_s.upcase}($1)")
        define_function function, all: ->(this) {
          partial = this.partial
          query = string.sub('$1', partial.query)
          [query, partial.attributes]
        }
      end

      def define_function2(function, string)
        define_function function, all: ->(this, operand) {
          partial = this.partial
          operand_p = Relational::Partial.wrap(operand).partial
          query = string.sub('$1', partial.query).sub('$2', operand_p.query)
          [query, partial.attributes + operand_p.attributes]
        }
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
        number_of_params = 0

        functions_for_drivers.each do |driver, body|
          Adapter.add_custom_function(function, driver, body)
          number_of_params = body.arity - 1
        end

        define_method(function) do |*params|
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

      def define_custom_method(method, methods_for_drivers)
        @methods ||= {}
        number_of_params = 0

        methods_for_drivers.each do |driver, body|
          @methods[driver.to_s] ||= {}
          @methods[driver.to_s][method] = body
          number_of_params = body.arity
        end

        at_methods = @methods
        # TODO: Precisa do bloco?
        current_driver = -> { Adapter.current_driver() }

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
end
