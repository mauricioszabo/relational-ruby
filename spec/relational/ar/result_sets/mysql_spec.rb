begin
require_relative 'shared'

module Relational::AR::ResultSets
  describe MySQL do
    it_should_behave_like 'a result set' do
      let(:connection) do
        exec = [[20, 'Foo'], [30, 'Bar']]
        exec.stub(fields: ['id', 'name'])
        conn = double(execute: exec)
      end
    end
  end
end

rescue LoadError
end

