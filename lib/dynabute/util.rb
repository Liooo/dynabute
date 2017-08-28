module Dynabute
  class Util
    class << self
      def nested_attributable_presence_validator(id_attr, id_relation_accessor, halt: false)
        return -> {
          attr = id_attr.to_sym
          if (persisted? && self[attr].nil?) || (new_record? && send(id_relation_accessor).nil?)
            errors[attr] << I18n.t('errors.messages.blank')
            return fail(:abort) if(halt)
          end
        }
      end

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
        Dynabute::Field::TYPES.map{|t| Util.value_relation_name(t) }
      end
    end
  end
end
