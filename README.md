# RELATIONAL

Relational is a library to do what I'd like to call "Object-Oriented SQL". It is
basically making OO languages understand SQL in a object-way, and not like a 
bunch of strings mixed with OO code. To be able to achieve this, it is important
that not a single SQL is generated by fragments of strings in the code, so there
is no "SQL String"-like object on this code.

## What is it for?

Rails 3 came with an excelent idea, but badly implemented: Arel. Arel is a library
that is able to create SQL fragments using only classes and objects. Unfortunatelly,
Arel is hightly opined software, like Rails and ActiveRecord, and it is being 
developed as an internal ActiveRecord's API, so it's difficult to find documentation
and to see what will be deprecated or not.

Furthermore, there is no way to make use of Arel's SUM, AVG, and other SQL functions
like "LIKE". At first, I wrote a wrapper around these methods, 
https://github.com/mauricioszabo/arel_operators, but these didn't work as I wanted: 
first, that LIKE became ILIKE on PostgreSQL (first problem of opinated software: it
depends on the author's opinion, even if SQL Standard dictates otherwise); second,
that ActiveRecord tries to be smart about some SQL fragments, like JOIN, and most of
the time it is not what we want; third, some methods like "SELECT" don't allow to
cancel the previous SELECT methods, so we cannot modify queries in a sane way.

Enter Relational.

## How it works?

Relational don't tries to be smart about your SQL: it gives you what you ask for. 
But, you don't need to use SQL fragments nor strings to compose your query 
(this is a feature, not a limitation-so, I won't accept Pull Requests to add 
String-SQL fragments). For instance:

```ruby
require 'relational'
people = Relational::Tables::Table.new('people')
age = people[:age]
is_teen = ((age >= 10) & (age < 20)).as('is_teenager')

sql = Relational::Selector.new(
  select: Relational::Select[is_teen], 
  from: Relational::ListOfAttributes[people],
  order: Relational::ListOfAttributes[is_teen]
)

puts sql.partial.to_pseudo_sql
# => SELECT ((people.age >= 10 AND people.age < 20)) is_teenager 
#    FROM people 
#    ORDER BY is_teenager
```

## Simple Documentation


### Relational::Attributes::*

Every class inside Attributes namespace is something that can be understandable
as an attribute in SQL. So, Literals are objects in Ruby that our SQL will 
understand, like `String`, `Fixnum`, `Date` and `Time`. There is a special kind 
that is the class `None`-it is a simple black-hole like condition. In this way,
you can concatenate your conditions like:

```ruby
people = Relational::Tables::Table.new('people')

condition = Relational::Attributes::None
condition = condition & (people[:age] > params[:age]) if params[:age]
condition = condition & (people[:name] == params[:name]) if params[:name]
```

There is also the special-case `All`, that is simply `*`. So, you can list all
attributes from all your FROM and JOIN clauses using just All.

### Relational::Tables::*

There are only two classes: at first, all tables are instantiated by `Table`, but 
you can use the `Alias` class so you can alias a table, or alias a SQL to use 
as a table:

```ruby
people = Relational::Tables::Table.new('people')

subselect = Relational::Selector.new(
  select: Relational::Select[Relational::Attributes::All], 
  from: Relational::ListOfAttributes[people]
)

aliased = subselect.as('aliased')

sql = Relational::Selector.new(
  select: Relational::Select[aliased[:id]], 
  from: Relational::ListOfAttributes[aliased],
  order: Relational::ListOfAttributes[aliased[:name]]
)

puts sql.partial.to_pseudo_sql
# => SELECT aliased.id FROM (SELECT * FROM people) aliased ORDER BY aliased.name
```

### Internals

Every SQL fragment in Relational returns a `PartialStatement`. Partial Statements
are composed by a query and a list of attributes. Queries are SQL fragments with placeholders (in this case, the `?` sign) and they must be translated to the "real" 
SQL counterpart by escaping each attribute. For instance, if we are using a JDBC 
adapter on JRuby, we can translate it to a `PreparedStatement`. If we're using rails,
we can use `sanitize_sql`.

Partial Statements have a method `to_pseudo_sql`, so it converts the SQL fragment AND 
the attributes to a SQL-Like string. It escapes some attributes, but **IT IS NOT 
SAFE**! Never use it on your code to generate real SQL, because **it doesn't escapes 
the string correctly**, and **it will not work on Date, Time, and classes that are 
not strings or numbers**. You have been warned.