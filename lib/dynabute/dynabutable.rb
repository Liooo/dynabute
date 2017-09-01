require 'dynabute/util'
require 'dynabute/joins'
require 'dynabute/nested_attributes'

module Dynabute
  module Dynabutable
    extend ActiveSupport::Concern

    included do
      include Joins::Dynabutable
      include NestedAttributes::API

      (Dynabute::Field::TYPES).each do |t|
        has_many Util.value_relation_name(t), class_name: Util.value_class_name(t), as: :dynabutable, inverse_of: 'dynabutable'
        accepts_nested_attributes_for Util.value_relation_name(t), reject_if: proc{ |param| param[:value].blank? }, allow_destroy: true
      end

      def self.dynabutes
        Dynabute::Field.for(self.to_s)
      end

      def self.dynabute_relation_names
        Util.all_value_relation_names
      end

      def dynabute_fields
        Dynabute::Field.for(self.class.to_s)
      end

      def dynabute_values
        dynabute_fields
          .group_by{|f| f.value_type }
          .map { |_, fields|
            send(Util.value_relation_name(fields.first.value_type))
          }.flatten.compact
      end

      def dynabute_value(name: nil, field_id: nil, field: nil)
        field = find_field(name, field_id, field)

        if field.has_many
          send(Util.value_relation_name(field.value_type)).select{|v| v.field_id == field.id }
        else
          send(Util.value_relation_name(field.value_type)).detect{|v| v.field_id == field.id }
        end
      end

      def build_dynabute_value(name: nil, field_id: nil, field: nil, **rest)
        field = find_field(name, field_id, field)
        send(Util.value_relation_name(field.value_type)).build(field_id: field.id, **rest)
      end

      def method_missing(*args)
        name = args[0]
        one = name.to_s.scan(/^dynabute_(.+)_value$/)[0]
        many = name.to_s.scan(/^dynabute_(.+)_values$/)[0]
        return super if one.nil? && many.nil?
        target = one ? one : many
        candidates = [target[0], target[0].gsub('_', ' ')]
        field = Dynabute::Field.find_by(name: candidates)
        return super if field.nil?
        dynabute_value(field: field)
      end

      private
      def find_field(name, id, field)
        name_or_id = {name: name, id: id}.compact
        return nil if name_or_id.blank? && field.blank?
        field_obj = field || Dynabute::Field.find_by(name_or_id.merge(target_model: self.class.to_s))
        fail Dynabute::FieldNotFound.new(name_or_id, field) if field_obj.nil?
        field_obj
      end

    end
  end
end
