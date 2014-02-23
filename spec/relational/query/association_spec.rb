require_relative '../../helper'

module Relational::Query
  describe Association do
    let(:people) { Relational::Tables::Table.new('people') }
    let(:addrs) { Relational::Tables::Table.new('addrs') }

    it 'defines an association with table and keys' do
      subject = Association.new(table: people, join_table: 'addrs', pk: 'id', fk: 'person_id')
      subject.join_table.should have_pseudo_sql('addrs')
      subject.condition.should have_pseudo_sql('people.id = addrs.person_id')
    end

    it 'defines an association with a table object' do
      subject = Association.new(table: people, join_table: addrs, pk: 'id', fk: 'person_id')
      subject.join_table.should have_pseudo_sql('addrs')
    end

    it 'defines an association with a specific condition' do
      subject = Association.new(table: people, join_table: addrs, condition:
        ((people[:id] > 10) & (people[:id] == addrs[:id])) )
      subject.condition.should have_pseudo_sql(
        '(people.id > 10 AND people.id = addrs.id)' )
    end

    it 'defines an table based on a Query object' do
      module TestFoo
        extend Relational::Query, self
        set_table_name 'foos'
      end

      subject = Association.new(table: people, mapper: 'TestFoo', pk: 'id', fk: 'person_id')
      subject.join_table.should have_pseudo_sql('foos')
      subject.condition.should have_pseudo_sql('people.id = foos.person_id')
    end
  end
end
