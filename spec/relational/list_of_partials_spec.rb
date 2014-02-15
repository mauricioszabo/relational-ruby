require_relative '../helper'

module Relational
  describe ListOfPartials do
    let(:people) { Relational::Tables::Table.new('people') }

    it 'represents a list of non-comma-separated partials' do
      select = ListOfPartials[people.id, people.name, people.age]
      select.should have_pseudo_sql "people.id people.name people.age"
    end

    it 'defines a list of attributes' do
      select = ListOfAttributes[people.id, people.name, people.age.as('foo')]
      select.should have_pseudo_sql "people.id, people.name, foo"
    end

    it 'uses the notation for SELECT in attributes' do
      select = Select[people.id, people.name, people.age.as('foo')]
      select.should have_pseudo_sql "SELECT people.id, people.name, (people.age) foo"
    end

    it 'represents DISTINCT selects' do
      select = Select[people.id, people.name, people.age].distinct
      select.should have_pseudo_sql "SELECT DISTINCT people.id, people.name, people.age"
    end

    it 'represents non-DISTINCT selects' do
      select = Select[people.id, people.name, people.age].distinct.indistinct
      select.should have_pseudo_sql "SELECT people.id, people.name, people.age"
    end

    it 'adds an attribute on a list' do
      select = (Select + people.id + people.name)
      select.should have_pseudo_sql "SELECT people.id, people.name"
      select.prepend(people.age) .should have_pseudo_sql "SELECT people.age, people.id, people.name"
    end
  end
end
