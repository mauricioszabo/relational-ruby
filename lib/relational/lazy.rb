module Relational
  module Lazy
    def lazy(name, &block)
      define_method name do
        @lazies ||= {}
        @lazies[name] ||= instance_exec(&block)
      end
    end
  end
end
