require 'csv_search/delegation'
require 'csv_search/algebra/between'

module CSVRecord
  class Relation
    include Delegation

    attr_reader :klass, :scope, :class_name

    def initialize(klass)
      @klass = klass
      @class_name = klass.name
      @scope = klass.data.map do |object|
        klass.new(object)
      end
    end

    def all
      self
    end

    def where(opts)
      scope.select! do |object|
        object if queries(opts) { |key, query| query.call(object.send(key)) }
      end
      self
    end

    def find_by(opts)
      scope.find do |object|
        object.values_at(*opts.keys) == opts.values
      end
    end

    def pluck(*columns)
      scope.map do |object|
        object.values_at(*columns).tap do |datas|
          break datas.first if columns.size == 1
        end
      end
    end

    def order(*columns)
      scope.sort_by! do |object|
        if columns.first.is_a?(Hash)
          columns.first.map do |column, dir|
            dir.to_sym == :desc ? -object.send(column) : object.send(column)
          end
        else
          columns.map { |column| object.send(column) }
        end
      end
      self
    end

    def group_by(&block)
      scope.group_by(&block)
    end

    def each(&block)
      scope.each(&block)
    end

    def each_with_index(&block)
      scope.each_with_index(&block)
    end

    def map(&block)
      scope.map(&block)
    end

    def present?
      scope.present?
    end

    def to_a
      scope
    end

    private

    def queries(opts)
      opts.all? do |key, value|
        next yield key, proc { |object| value == object } unless value.is_a?(Hash)

        value.all? do |vk, vv|
          case vk
            # where(a: {
            #   between: [a, b]
            # })
          when :between
            yield key, Algebra::Between.new(minimum: vv.minimum, maximum: vv.maximum).prok
          end
        end
      end
    end
  end
end
