module Dynabute
  module Util
    def value_class_name(type)
      name = %i(select).include?(type.to_sym) ? :integer : type
      "Dynabute::Values::#{name.to_s.classify}Value"
    end
    module_function :value_class_name

    def value_relation_name(type)
      %i(select).include?(type.to_sym) ?
        :integer_values :
        "#{type}_values".to_sym
    end
    module_function :value_relation_name

    def all_value_relation_names
      Dynabute::Field::TYPES.map{|t| Util.value_relation_name(t).uniq }
    end
    module_function :all_value_relation_names
  end
end
