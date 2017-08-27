require 'dynabute/util'

module Dynabute
  class Option < ActiveRecord::Base
    def self.table_name_prefix; Util.table_name_prefix; end
    belongs_to :field, class_name: 'Dynabute::Field'
    has_many :values, class_name: Util.value_class_name(:integer), foreign_key: 'value'
    validates_presence_of :label
    validates :label, uniqueness: { scope: ['field_id'] }
    before_save :validates_field_id_presence # not using validates() to let through creation by nested attributes

    def validates_field_id_presence
      return errors[:field_id] << I18n.t('errors.messages.blank') if (self.persisted? && self.field_id.nil?) || (self.new_record? && self.field.nil?)
    end
  end
end
