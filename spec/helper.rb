require 'relational'

RSpec::Matchers.define :have_pseudo_sql do |sql|
  match do |partial|
    partial.partial.to_pseudo_sql == sql
  end
end
