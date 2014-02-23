require_relative '../../helper'

module Relational::Query
  describe Joins do
    module People
      extend Relational::Query
      extend self

      has :many, :addresses, table: 'addrs', pk: 'id', fk: 'person_id'
      has :many, :users, class: 'Users', pk: 'id', fk: 'person_id'
    end

    module Users
      extend Relational::Query
      extend self
    end

    it 'understands join into another table' do
      People.joins(:addresses).should have_pseudo_sql "SELECT people.* FROM people " +
        "INNER JOIN addrs ON people.id = addrs.person_id"
    end

    it 'understands LEFT join into another table' do
      People.left_joins(:addresses).should have_pseudo_sql "SELECT people.* FROM people " +
        "LEFT JOIN addrs ON people.id = addrs.person_id"
    end

    it 'understands multiple joins' do
      People.left_joins(:addresses, :users).should have_pseudo_sql "SELECT people.* FROM people " +
        "LEFT JOIN addrs ON people.id = addrs.person_id " +
        "LEFT JOIN users ON people.id = users.person_id"
    end
  end
end
