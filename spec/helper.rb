require 'relational'

RSpec::Matchers.define :have_pseudo_sql do |sql|
  match do |partial|
    partial.partial.to_pseudo_sql == sql
  end

  failure_message_for_should do |partial|
    if partial.respond_to?(:partial)
      "expected partial to have pseudo-sql:\n\t#{sql}\nbut it was:\n\t#{partial.partial.to_pseudo_sql}"
    else
      "#{partial.inspect} doesn't even have :partial method..."
    end
  end
end
