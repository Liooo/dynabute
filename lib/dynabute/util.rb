module Dynabute
  class Util
    class << self
      def table_name_prefix
        'dynabute_'
      end

      def value_class_name(type)
        "Dynabute::Values::#{type.to_s.classify}Value"
      end

      def value_relation_name(type)
        "#{type}_values".to_sym
      end

      def all_value_relation_names
        Dynabute::Field::TYPES.map{|t| Util.value_relation_name(t).uniq }
      end
    end
  end
end
