module Nlp

  class SqlQuery
    def initialize(base)
      @base = base
      @from = Array.new
      @select = Hash.new
      @where = Hash.new
    end
    def addTable(table, index)
      elem = BaseIndex.new(table, index)
      @from << elem
    end
    def addField(table, field, index)
      elem = BaseIndex.new(field, index)
      @select.has_key?(table) ? @select[table] << elem : @select[table] = [elem]
    end
    def addCondition(table, field, operator, value)
      condition = SqlCondition.new(table + "." + field, operator, value)
      @where.has_key?(table) ? @where[table] << condition : @where[table] = [condition]
    end
    def to_s
      ret = ""
      @from.each do |tableObj|
        table = tableObj.getName
        if @select.has_key?(table)
          ret += "SELECT " + @select[table].join(", ")
        end
        ret += " FROM " + tableObj.to_s
        if @where.has_key?(table)
          ret += " WHERE " + @where[table].join(" AND ")
        end
      end
      return ret
    end
  end
  class SqlCondition
    def initialize(field, operator, value)
      @field = field
      @operator = operator
      @value = value
    end
    def to_s
      return @field + " " + @operator + " " + @value
    end
  end
  class BaseIndex
    def initialize(name, index)
      @name = name
      @index = index
    end
    def getName
      return @name
    end
    def to_s
      return "(" + @name + "@" + @index.to_s + ")"
    end
  end
end
