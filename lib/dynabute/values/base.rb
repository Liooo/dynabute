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
      before_create :reject_duplication_for_has_one

      def value_type
        field.value_type
      end

      private
      def reject_duplication_for_has_one
        return if field.has_many
        return unless self.class.exists?(field_id: field_id, dynabutable_id: dynabutable_id, dynabutable_type: dynabutable_type)
        self.errors[:base] << 'Multiple records for has_one relationship detected'
        throw :abort
      end
    end

  end

end
