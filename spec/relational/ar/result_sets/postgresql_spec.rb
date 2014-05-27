begin
require_relative 'shared'

module Relational::AR::ResultSets
  describe PostgreSQL do
    it_should_behave_like 'a result set' do
      let(:connection) { double(execute: [
        {'id' => 20, 'name' => 'Foo'}, {'id' => 30, 'name' => 'Bar'}]) }
    end
  end
end

rescue LoadError
end

