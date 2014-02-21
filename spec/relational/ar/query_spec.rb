begin
require 'active_record'
require_relative '../../helper'

module Relational::AR
  describe Query do
    class Person < ActiveRecord::Base
    end

    class Address < ActiveRecord::Base
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
          mock = mock("User"))

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
