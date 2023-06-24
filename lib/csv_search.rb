require 'csv'
require 'csv_search/relation'

module CSVSearch
  class Base
    class << self
      attr_reader :data

      @data = []

      def source(file_path)
        @data = CSV.foreach(file_path, headers: true).map(&:to_h)
      end

      def column_names
        @column_names ||= @data.first.keys.map(&:to_sym)
      end

      def all
        Relation.new(self).all
      end

      def where(opts)
        Relation.new(self).where(opts)
      end

      def find_by(opts)
        Relation.new(self).find_by(opts)
      end

      def order(*columns)
        Relation.new(self).order(*columns)
      end

      def pluck(*columns)
        Relation.new(self).pluck(*columns)
      end
    end

    def initialize(object)
      object.each_pair do |key, value|
        next if self.class.column_names.exclude?(key.to_sym)

        define_singleton_method(key) do
          instance_variable_get("@#{key}") || instance_variable_set("@#{key}", value)
        end
      end
    end

    def attributes
      Hash[self.class.column_names.map { |column| [column, send(column)] }]
    end

    def values_at(*columns)
      columns.map { |column| send(column) }
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      values_at(*self.class.column_names) == other.values_at(*self.class.column_names)
    end
  end
end
