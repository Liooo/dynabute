module Dynabute
  module Values
    class SelectValue < ActiveRecord::Base
      include Dynabute::Values::Base
      belongs_to :option, class_name: "Dynabute::Option", foreign_key: 'value'
      validate :ensure_option_is_in_same_field

      def ensure_option_is_in_same_field
        if option && (option.field_id != field_id)
          errors[:value] << I18n.t('errors.messages.dynabutes.wrong_field_option',
                      default: 'is pointing to the option for other dynabute field')
        end
      end

    end
  end
end
