require_relative 'query/joins'

module Relational
  module Query
    include Partial

    class NO_OPT
    end

    include Query::Joins

    module Mapper
      def initialize(options)
        @options = options
      end
    end

    class PartialQuery
      include Query
      include Mapper
    end

    def set_composer(composer)
      options[:composer] = composer
    end

    def composer
      options[:composer]
    end

    def table
      options[:table]
    end

    def set_table(table)
      options[:table] = table
    end

    def table_name
      options[:table].representation
    end

    def set_table_name(name)
      set_table Relational::Tables::Table.new(name)
    end

    def all
      new_partial_query
    end

    def selector
      options[:selector] || Selector.new(
        select: Select[table.*],
        from: ListOfAttributes[table]
      )
    end

    def select(*fields)
      if fields.empty?
        selector.opt(:select)
      else
        select = Select[*convert_fields(fields)]
        new_partial_query(select: select)
      end
    end

    def distinct(*fields)
      select = Select[*convert_fields(fields)].distinct
      new_partial_query(select: select)
    end

    def query
      new_query = all
      t = table
      new_query.singleton_class.send :define_method, :[] do |value|
        t[value]
      end

      new_query.singleton_class.send :define_method, :method_missing do |method, *args, &b|
        if args.size == 0 && b.nil?
          t[method]
        else
          super
        end
      end

      yield new_query
    end

    def from(*tables)
      if(tables.empty?)
        opt(:from)
      else
        fields = convert_fields(tables)
        new_partial_query(from: ListOfAttributes[*fields])
      end
    end

    def where(condition=NO_OPT, &block)
      new_condition(:where, condition, &block)
    end

    def restrict(condition=NO_OPT, &block)
      condition = where & extract_condition(condition, &block)
      new_partial_query(where: condition)
    end

    def having(condition=NO_OPT, &block)
      new_condition(:having, condition, &block)
    end

    def restrict_having(condition=NO_OPT, &block)
      condition = having & extract_condition(condition, &block)
      new_partial_query(having: condition)
    end

    def new_condition(kind, condition, &block)
      if NO_OPT == condition && block.nil?
        selector.opt(kind)
      else
        new_partial_query(kind => extract_condition(condition, &block))
      end
    end
    private :new_condition

    def extract_condition(condition, &block)
      if condition.is_a?(Hash)
        condition.inject(Attributes::None) do |grouping, (key, value)|
          grouping & (table[key] === value)
        end
      elsif block
        block.call(table)
      else
        condition
      end
    end
    private :extract_condition

    def group(*fields)
      if fields.empty?
        selector.opt(:group)
      else
        group = ListOfAttributes[*convert_fields(fields)]
        new_partial_query(group: group)
      end
    end

    def join(*joins_or_tables)
      if joins_or_tables.size == 0
        selector.opt(:join)
      elsif joins_or_tables.size == 1 && joins_or_tables[0].is_a?(ListOfPartials)
        new_partial_query(join: joins_or_tables[0])
      else
        Relational::Joins::JoinHelper.new(self, table, joins_or_tables, :inner)
      end
    end

    def left_join(*tables)
      Relational::Joins::JoinHelper.new(self, table, tables, :left)
    end

    def order(*attributes)
      if(attributes.empty?)
        selector.opt(:order)
      else
        fields = convert_fields(attributes)
        new_partial_query(order: ListOfAttributes[*fields])
      end
    end

    def convert_fields(fields)
      fields.flat_map do |field|
        case field
        when ListOfPartials then convert_fields(field.to_a)
        when Symbol then table[field]
        when Attributes::Literal
          if field.literal.is_a?(Symbol)
            table[field.literal]
          else
            field
          end
        else [Partial.wrap(field)]
        end
      end
    end
    private :convert_fields

    def limit(number = nil)
      if(number)
        new_partial_query(limit: number)
      else
        selector.opt(:limit)
      end
    end

    def offset(number=nil)
      if(number)
        new_partial_query(offset: number)
      else
        selector.opt(:offset)
      end
    end

    def new_partial_query(selector_options={})
      new_selector = selector.copy(selector_options)
      instance = composer.new(options.merge(selector: new_selector))

      self_module = options[:self_module] ||= self
      if self_module.class == Module
        instance.extend self_module
      else
        instance
      end
    end
    private :new_partial_query

    def count_query
      self_alias = self.as('count_query')
      Selector.new(
        from: Relational::ListOfAttributes[self_alias],
        select: Relational::Select[Attributes::All.count.as('count')]
      )
    end

    def as(alias_name)
      selector.as(alias_name)
    end

    def partial
      selector.partial
    end

    def options
      if @options.nil?
        @options = default_options
      else
        @options
      end
    end
    protected :options

    def default_options()
      table_name = default_table_name
      {
        composer: PartialQuery,
        table: Tables::Table.new(table_name)
      }
    end
    private :default_options

    def default_table_name
      class_name = if(self.is_a?(Module))
        name.to_s.split("::").last.to_s
      else
        self.class.name.to_s.split("::").last
      end

      class_name.gsub!(/[A-Z]/) { |letter| "_" + letter.downcase }
      if class_name[0] == "_"
        class_name[1..-1]
      else
        class_name
      end
    end
    private :default_table_name
  end
end
