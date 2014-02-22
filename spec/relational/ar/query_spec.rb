begin
require 'active_record'
require_relative '../../helper'

module Relational::AR
  describe Query do
    class Person < ActiveRecord::Base
      has_many :addresses
    end

    class Address < ActiveRecord::Base
      belongs_to :person
    end

    module People
      include Query
      extend self
      set_model Person
    end

    before :all do
      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: ':memory:'
      )
      connection = ActiveRecord::Base.connection
      connection.execute "CREATE TABLE people (
        id INTEGER PRIMARY KEY, name VARCHAR(255), age INTEGER)"
      connection.execute "CREATE TABLE addresses(
        id INTEGER PRIMARY KEY, address VARCHAR(255), person_id INTEGER)"
      @person1 = Person.create!(name: "Foo", age: 25)
      @person2 = Person.create!(name: "Bar", age: 25)
      @person3 = Person.create!(name: "Foo", age: 20)
    end

    it 'finds users' do
      people = People.where(name: 'Bar')
      people.results.to_a.should == [@person2]
    end

    it 'counts the results' do
      people = People.where(name: 'Foo')
      people.count.should == 2
    end

    context 'when joining' do
      class Phone < ActiveRecord::Base
        belongs_to :address
      end

      Address.has_many :phones

      before :all do
        Phone.connection.execute "CREATE TABLE phones (id INTEGER PRIMARY KEY,
          number VARCHAR(255), address_id INTEGER)"
        @person2.addresses.create!(address: "Bar 1")
        address = @person2.addresses.create!(address: "Bar 2")
        address.phones.create!(number: '5555-4444')
      end

      it 'joins AR-style' do
        people = People.joins(:addresses)
        people.results.to_a.should == [@person2, @person2]
      end

      it 'left joins AR-style' do
        people = People.left_joins(:addresses)
        people.results.count.should == 4
      end

      it 'nest-joins using a hash syntax' do
        people = People.joins(addresses: :phones)
        people.results.to_a.should == [@person2]
      end

      it 'joins belongs_to' do
        module Foo
          include Query
          extend self
          set_model Phone
        end

        Foo.joins(:address).should have_pseudo_sql "SELECT phones.* FROM phones " +
          "INNER JOIN addresses ON phones.address_id = addresses.id"
      end

      it 'joins has_and_belongs_to_many' do
        Person.has_and_belongs_to_many :phones
        People.joins(:phones).should have_pseudo_sql "SELECT people.* FROM people " +
          "INNER JOIN people_phones ON people.id = people_phones.person_id " +
          "INNER JOIN phones ON people_phones.phone_id = phones.id"
      end
    end

    context 'results' do
      it 'is equal results with same attributes' do
        people1 = People.where(name: 'Bar').results
        people2 = People.where(name: 'Bar').results
        people1.should == people2
      end

      it 'behaves as an array' do
        people = People.where(name: 'Foo').order(:age).results
        people.first.age.should == 20
        people[-1].age.should == 25
      end

      it 'counts' do
        people = People.where(name: 'Foo').results
        people.size.should == 2
      end

      it 'caches results' do
        Person.should_receive(:instantiate).once.and_return(
          mock = double("User"))

        people = People.where(name: "Bar")
        results = people.cached_results

        results.to_a.should == [mock]
        results.to_a.should == [mock]
      end
    end
  end
end

rescue LoadError
end
