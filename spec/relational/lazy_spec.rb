require_relative '../helper'

describe Relational::Lazy do
  class Some
    extend Relational::Lazy

    attr_reader :counter
    lazy(:name) { increment; "Foo" }

    def initialize
      @counter = 0
    end

    def increment
      @counter += 1
    end
  end

  it 'caches the value' do
    some = Some.new
    some.counter.should == 0
    some.name.should == "Foo"
    some.counter.should == 1
  end
end
