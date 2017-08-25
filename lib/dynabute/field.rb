require 'dynabute/util'
require 'dynabute/joins'

module Dynabute
  class Field < ActiveRecord::Base
    include Joins::Field
    def self.table_name_prefix; 'dynabute_'; end

    TYPES = %w(string integer boolean datetime select)
    validates :value_type, inclusion: {in: TYPES}
    scope :for, ->(klass){ where(target_model: klass) }
    has_many :options, class_name: 'Dynabute::Option', dependent: :destroy
    accepts_nested_attributes_for :options, allow_destroy: true
    def is_select?
      ['select'].include? value_type
    end

    def value_class
      type = is_select? ? :integer : value_type
      Util.value_class_name(type).safe_constantize
    end

    def self.<<(records)
      if records.respond_to? :each
        records.each {|r| r.update!(target_model: get_parent_class_name) }
      else
        records.update!(target_model: get_parent_class_name)
      end
      all
    end

    private
    def self.get_parent_class_name
      all.where_clause.binds.detect{|w| w.name == 'target_model'}.try(:value)
    end
  end
end
