module CSVRecord
  module Delegation
    def self.included(base)
      base.include ClassSpecificRelation
    end

    module ClassSpecificRelation
      def delegate_to_scoped_klass(method)
        instance_eval(@klass.public_method(method).source)
      end

      protected

      def method_missing(method, *args, &block)
        if @klass.respond_to?(method)
          delegate_to_scoped_klass(method)
          public_send(method, *args, &block)
        else
          super
        end
      end
    end
  end
end
