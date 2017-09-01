require 'dynabute/util'

module Dynabute
  class Option < ActiveRecord::Base
    def self.table_name_prefix; Util.table_name_prefix; end
    belongs_to :field, class_name: 'Dynabute::Field'
    has_many :values, class_name: Util.value_class_name(:select), foreign_key: 'value', inverse_of: 'option'
    validates :label, presence: true, uniqueness: { scope: ['field_id'] }
    validate Util.nested_attributable_presence_validator(:field_id, :field)
  end
end
