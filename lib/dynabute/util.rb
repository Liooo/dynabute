module Dynabute
  class Util
    class << self
      def table_name_prefix
        'dynabute_'
      end

      def value_class_name(type)
        name = %i(select).include?(type.to_sym) ? :integer : type
        "Dynabute::Values::#{name.to_s.classify}Value"
      end

      def value_relation_name(type)
        %i(select).include?(type.to_sym) ?
          :integer_values :
          "#{type}_values".to_sym
      end

      def all_value_relation_names
        Dynabute::Field::TYPES.map{|t| Util.value_relation_name(t).uniq }
      end
    end
  end
end
