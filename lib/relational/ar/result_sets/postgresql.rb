require_relative 'base'

module Relational
  module AR
    module ResultSets
      class PostgreSQL < Base
        def each
          finished = false
          connection, pg = get_connections
          if pg.respond_to?(:set_single_row_mode)
            pg.set_single_row_mode
            while(rs = pg.get_result)
              yield rs.to_a.first
            end
          else
            pg.get_result.each { |row| yield row }
          end
          finished = true
        ensure
          pg.reset unless finished
          @connection.connection_pool.checkin(connection) if connection
        end

        def get_connections
          connection = @connection.connection_pool.checkout
          pg = connection.instance_variable_get(:@connection)
          pg.send_query(@query)
          [connection, pg]
        end
        private :get_connections
      end
    end
  end
end
