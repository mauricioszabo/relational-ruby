module Relational
  module Adapters
    extend self

    # Gets the instance that translates Relational's commands and methods
    # into specific SQL functions and commands
    def instance
      @instance ||= begin
        get_driver(@current_driver || 'default')
      end
    end

    def get_driver(driver_name)
      _, klass = @drivers.find { |(key, value)| driver_name.match(key) }
      raise ArgumentError, "no suitable driver found for #@current_driver}" if klass.nil?
      klass
    end

    # Defines which driver will translate Relational's commands into SQL ones
    def define_driver(driver)
      @instance = nil
      @current_driver = driver
    end

    def register_driver(driver, klass)
      @drivers ||= []
      @drivers.insert(0, [driver, klass])
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
        driver = driver == :all ? 'default' : driver.to_s
        get_driver(driver).add_function(function, body)
        number_of_params = body.arity - 1
      end

      Relational::Attributes::AttributeLike.send(:define_method, function) do |*params|
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

    register_driver('default', Default)
  end
end
