require 'active_record'
require_relative '../../../helper'

shared_examples "a result set" do
  it 'transforms into a array' do
    rs = described_class.new(connection, 'SELECT *')
    rs.to_a.should == [
      {'id' => 20, 'name' => 'Foo'},
      {'id' => 30, 'name' => 'Bar'}
    ]
  end
end
