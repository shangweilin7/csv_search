module CSVRecord
  module Algebra
    class Between
      attr_reader :prok

      def initialize(args = {})
        minimum = args[:minimum] || 0
        maximum = args[:maximum] || BigDecimal::INFINITY
        @prok = proc { |object| object >= minimum && object <= maximum }
      end
    end
  end
end
