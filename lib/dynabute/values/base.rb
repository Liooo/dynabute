require 'dynabute/util'

module Dynabute::Values
  module Base
    extend ActiveSupport::Concern

    included do
      def self.table_name_prefix; Dynabute::Util.table_name_prefix; end
      belongs_to :dynabutable, polymorphic: true
      belongs_to :field, class_name: 'Dynabute::Field'
      validate Dynabute::Util.nested_attributable_presence_validator(:field_id, :field)
      validate Dynabute::Util.nested_attributable_presence_validator(:dynabutable_id, :dynabutable)
      validate Dynabute::Util.nested_attributable_presence_validator(:dynabutable_type, :dynabutable)

      def value_type
        field.value_type
      end
    end

  end

end
