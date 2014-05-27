module Relational
  module AR
    module ResultSets
      def self.for_db(connection, query)
        case connection.adapter_name
          when /sqlite/i then Relational::AR::ResultSets::SQLite.new(connection, query)
          when /mysql/i then Relational::AR::ResultSets::MySQL.new(connection, query)
          when /oracle/i then Relational::AR::ResultSets::Oracle.new(connection, query)
          when /postgres/i then Relational::AR::ResultSets::PostgreSQL.new(connection, query)
        end
      end
    end
  end
end

require_relative 'result_sets/sqlite'
require_relative 'result_sets/mysql'
require_relative 'result_sets/oracle'
require_relative 'result_sets/postgresql'
