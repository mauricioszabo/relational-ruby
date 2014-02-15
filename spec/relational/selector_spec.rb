require_relative '../helper'

module Relational
  describe Selector do
    let(:people) { Relational::Tables::Table.new('people') }

    let(:select) { Select[people.*] }
    let(:selector) { Selector.new(from: ListOfPartials[people], select: select) }

    context 'on SQL creation' do
      it "creates a query with or without WHERE" do
        selector.should have_pseudo_sql "SELECT people.* FROM people"
        selector2 = selector.copy(where: (people["id"] == 10))
        selector2.should have_pseudo_sql "SELECT people.* FROM people WHERE people.id = 10"
      end

      it 'creates a query with multiple tables on FROM clause' do
        selector2 = selector.copy(from: ListOfAttributes[people, selector.as('other')])
        selector2.should have_pseudo_sql (
          "SELECT people.* FROM people, ("+
          "SELECT people.* FROM people) other"
        )
      end

      it 'creates a query with GROUP BY clause' do
        selector.copy(group: ListOfPartials[people[:name]]).should have_pseudo_sql(
          "SELECT people.* FROM people GROUP BY people.name")
      end

      it 'creates a query with HAVING clause' do
        selector.copy(having: (people[:id] == 10)).should have_pseudo_sql(
          "SELECT people.* FROM people HAVING people.id = 10")
      end

      it 'creates a query with joins' do
        addresses = Relational::Tables::Table.new('addresses')
        logins = Relational::Tables::Table.new('logins')

        join_selector = selector.copy(join: ListOfPartials[
          Joins::LeftJoin.new(addresses, addresses[:people_id] == people[:id]),
          Joins::InnerJoin.new(logins, logins[:people_id] == people[:id]),
        ])

        join_selector.should have_pseudo_sql(
          "SELECT people.* FROM people " +
          "LEFT JOIN addresses ON addresses.people_id = people.id " +
          "INNER JOIN logins ON logins.people_id = people.id"
        )
      end

      it 'creates a query with ORDER BY clause' do
        selector.copy(order: ListOfPartials[people[:name]]).should have_pseudo_sql(
          "SELECT people.* FROM people ORDER BY people.name")
      end
    end

    #it "searches for records in a database" do
    #  selector2 = selector.copy(where: (people("id") <= 2), connection=connection)
    #  ids = selector2.results.map(_ attribute 'id as Int)
    #  ids.toList should be === List(1, 2)
    #end

    #  "search with a string" in {
    #    val selector2 = selector.copy(where=(people("name") == "Foo"), connection=connection)
    #    val ids = selector2.results.map(_ attribute 'id as Int)
    #    ids.toList should be === List(1, 2)
    #  }

    #  "select using operations" in {
    #    val selector2 = selector.copy(
    #      select=Select.select(people, people('id) == 1),
    #      connection=connection
    #    )
    #    val results = selector2.results.map(_.attribute.values.toList(0).value).toList
    #    results should be === List("true", "false", "false")
    #  }

    #  "With pagination" should {
    #    "paginate the results" in {
    #      val s = selector.copy(limit=1, offset=2)
    #      s.partial.toPseudoSQL should be === "SELECT people.* FROM people LIMIT 1 OFFSET 2"
    #    }
    #  }

    #  "search with a date" in {
    #    pending
    #    val selector = Selector(from=List(people), select=select,
    #      where=(people("birth") < java.sql.Date.valueOf("1990-01-01")), connection=connection)
    #    val ids = selector.results.map(_ attribute 'id as Int)
    #    ids.toList should be === List(1, 3)
    #  }
    #}
  end
end
