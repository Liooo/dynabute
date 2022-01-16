require 'dynabute/util'
require 'dynabute/joins'
require 'dynabute/nested_attributes'

module Dynabute
  module Dynabutable
    class ValueNotFound < StandardError; end
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
        field_obj = find_field(name, field_id, field)
        field_values = send(Util.value_relation_name(field_obj.value_type))
        field_value = if field_obj.has_many
          field_values.select{ |v| v.field_id == field_obj.id }
        else
          field_values.detect{ |v| v.field_id == field_obj.id }
        end
        field_value
      end

      def build_dynabute_value(name: nil, field_id: nil, field: nil, **rest)
        field_obj = find_field(name, field_id, field)
        send(Util.value_relation_name(field_obj.value_type)).build(field_id: field_obj.id, **rest)
      end

      # Returns value attribute for specified field.
      # If field can have multiple values for single target model object,
      # an array of values is returned, unless specific value_id is provided.
      def get_dynabute_value(name: nil, field_id: nil, field: nil, value_id: nil)
        field_obj = find_field(name, field_id, field)
        value_obj = dynabute_value(field: field_obj)
        return unless value_obj
        if field_obj.has_many && value_id
          value_obj = value_obj.detect{|v| v.id == value_id}
        end
        value_obj.is_a?(Array) ? value_obj.map(&:value) : value_obj&.value
      end

      # Sets the value in the target model object nested attribute structure.
      # If field can have multiple values for single target model object,
      # a new value will be added, unless specific value_id is provided.
      #
      # This method does not store changes in the database. "save" method should
      # be called on target model to store all changes, or individually on every
      # value record returned by this method.
      def set_dynabute_value(name: nil, field_id: nil, field: nil, value: nil, value_id: nil)
        field_obj = find_field(name, field_id, field)
        value_obj = dynabute_value(field: field_obj)
        if field_obj.has_many
          if value_id
            value_obj = value_obj.detect{|v| v.id == value_id} if value_obj
            fail ValueNotFound unless value_obj
          else
            value_obj = build_dynabute_value(field: field_obj)
          end
        else
          value_obj ||= build_dynabute_value(field: field_obj)
        end
        value_obj.value = value
        value_obj
      end

      # Removes value from database and keeps dynabute relations up-to-date.
      # If field can have multiple values for single target model object,
      # all values will be removed, unless specific value_id is provided.
      #
      # This method stores changes in the database
      def remove_dynabute_value(name: nil, field_id: nil, field: nil, value_id: nil)
        field_obj = find_field(name, field_id, field)
        value_obj = dynabute_value(field: field_obj)
        if value_obj && field_obj.has_many && value_id
          value_obj = value_obj.detect{|v| v.id == value_id}
        end
        if value_obj
          result_obj = send(Util.value_relation_name(field_obj.value_type)).destroy(value_obj)
          value_obj.is_a?(Array) ? result_obj : result_obj.first
        end
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
        # Validate field argument
        if field
          unless field.is_a?(Dynabute::Field)
            fail ArgumentError, 'Argument field must be Dynabute::Field'
          end
          return field
        end
        name_or_id = {}
        # Validate name argument
        if name
          unless name.is_a?(String) || name.is_a?(Symbol)
            fail ArgumentError, 'Argument name must be String or Symbol'
          end
          name_or_id[:name] = name.to_s
        end
        # Validate id argument
        if id
          unless id.is_a?(Integer)
            fail ArgumentError, 'Argument id must be Integer'
          end
          name_or_id[:id] = id
        end
        name_or_id.reject!{ |k, v| v.blank? }
        fail ArgumentError, 'Invalid arguments' if name_or_id.blank?
        field_obj = Dynabute::Field.find_by(name_or_id.merge(target_model: self.class.to_s))
        fail Dynabute::FieldNotFound.new(name_or_id) if field_obj.nil?
        field_obj
      end

    end
  end
end
