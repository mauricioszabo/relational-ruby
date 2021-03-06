require_relative '../helper'

module Relational
  describe Query do
    class People
      extend Query
    end

    it "finds all records on a table" do
      result = People.all
      result.should have_pseudo_sql "SELECT people.* FROM people"
    end

    it 'subselects using FROM' do
      ralias = People.where(id: 10).as('p')
      result = People.from(ralias).select(ralias[:id])
      result.should have_pseudo_sql "SELECT p.id FROM ("+
        "SELECT people.* FROM people WHERE people.id = 10) p"
    end

    it "finds records on a table" do
      result = People.where { |p| (p[:id] > 1) & (p[:id] < 3) }.select(:id, :name)
      result.should have_pseudo_sql "SELECT people.id, people.name " +
        "FROM people WHERE (people.id > 1 AND people.id < 3)"
    end

    it "finds using rails-like WHERE" do
      result = People.where(id: 1, name: 'foo')
      result.should have_pseudo_sql "SELECT people.* FROM people " +
        "WHERE (people.id = 1 AND people.name = 'foo')"
    end

    it 'restrict search using "restrict" to define a "AND-WHERE-kind" of condition' do
      result = People.restrict(name: 'foo').restrict { |p| p[:id] > 10 }
      result.should have_pseudo_sql "SELECT people.* FROM people " +
        "WHERE (people.name = 'foo' AND people.id > 10)"
    end

    it "finds records using HAVING" do
      result = People.having { |p| (p[:id] > 1) & (p[:id] < 3) }.select(:id, :name).group(:id)
      result.should have_pseudo_sql "SELECT people.id, people.name FROM people "+
        "GROUP BY people.id HAVING (people.id > 1 AND people.id < 3)"
    end

    it 'restrict search using "restrict_having" to define a "AND-HAVING-kind" of condition' do
      result = People.restrict_having(name: 'foo').restrict_having { |p| p[:id] > 10 }
      result.should have_pseudo_sql "SELECT people.* FROM people " +
        "HAVING (people.name = 'foo' AND people.id > 10)"
    end

    it "finds records reusing 'table' object" do
      result = People.query { |p| p.where(p.id > 10).select(p[:id], p[:name]) }
      result.should have_pseudo_sql "SELECT people.id, people.name FROM people "+
        "WHERE people.id > 10"
    end

    it "finds distinct records" do
      People.distinct(:id, :name).should have_pseudo_sql "SELECT DISTINCT "+
        "people.id, people.name FROM people"
    end

    it 'selects correctly fields' do
      result = People.select(:id)
      result.should have_pseudo_sql "SELECT people.id FROM people"

      result = result.select(:name)
      result.should have_pseudo_sql "SELECT people.name FROM people"

      result = result.select(result.select + :id)
      result.should have_pseudo_sql "SELECT people.name, people.id FROM people"

      result = result.select(:age, result.select)
      result.should have_pseudo_sql "SELECT people.age, people.name, people.id FROM people"
    end

    it "orders the query" do
      result = People.query { |p| p.order(p[:id].asc) }
      result.should have_pseudo_sql "SELECT people.* FROM people ORDER BY (people.id) ASC"

      result = People.query { |p| p.order(p[:id].desc) }
      result.should have_pseudo_sql "SELECT people.* FROM people ORDER BY (people.id) DESC"
    end

    it "joins another table" do
      address = People.join(:addresses).on { |p, a| p[:id] == a[:person_id] }
      address.should have_pseudo_sql "SELECT people.* FROM people " +
        "INNER JOIN addresses ON people.id = addresses.person_id"
    end

    it "joins another with a join object" do
      table = Tables::Table.new("addresses")
      join = Joins::InnerJoin.new(table, table[:person_id] == People.table[:id])
      address = People.join(ListOfPartials[join])
      address.should have_pseudo_sql "SELECT people.* FROM people " +
        "INNER JOIN addresses ON addresses.person_id = people.id"
    end

    it "left joins another table" do
      address = People.left_join(:addresses).on { |p, a| p[:id] == a[:person_id] }
      address.should have_pseudo_sql "SELECT people.* FROM people " +
        "LEFT JOIN addresses ON people.id = addresses.person_id"
    end

    it 'chain joins to reach deeper tables' do
      zip_codes = People.join(:addresses, :zip_codes)
        .on { |p, a| p[:id] == a[:person_id] }
        .on { |a, z| a[:zip_id] == z[:id] }

      zip_codes.should have_pseudo_sql "SELECT people.* FROM people " +
        "INNER JOIN addresses ON people.id = addresses.person_id " +
        "INNER JOIN zip_codes ON addresses.zip_id = zip_codes.id"
    end

    it 'has a query to count records' do
      result = People.select(:id).where(id: 10)
      result.count_query.should have_pseudo_sql "SELECT (COUNT(*)) count FROM (" +
        "SELECT people.id FROM people WHERE people.id = 10) count_query"
    end

    it 'leaves to the driver how to fetch results' do
      class Something
        include Query
        include Mapper

        def results
          if where.partial.to_pseudo_sql.match("people.name = 'foo'")
            ['foo']
          else
            ['foo', 'bar']
          end
        end
      end

      People.set_composer(Something)
      People.where(name: 'foo').results.should == ['foo']
      People.where(name: 'bar').restrict(age: 17).results.should == ['foo', 'bar']
    end

    it 'extends the "finder" if it is a module' do
      module People2
        include Query
        extend self

        set_table_name 'people'

        def by_name(name)
          where(where & (table[:name] == name))
        end

        def by_age(age)
          where(where & (table[:age] == age))
        end
      end

      People2.by_name('foo').by_age(12).should have_pseudo_sql  "SELECT people.* "+
        "FROM people WHERE (people.name = 'foo' AND people.age = 12)"
    end
  end
end
