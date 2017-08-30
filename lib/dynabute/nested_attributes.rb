require 'dynabute/util'

module Dynabute
  module NestedAttributes
    class FieldNotSpecified < StandardError; end
    class Builder
      def initialize(attributes_list, dynabutee)
        unless attributes_list.is_a?(Hash) || attributes_list.is_a?(Array)
          raise ArgumentError, "Hash or Array expected, got #{attributes_list.class.name} (#{attributes_list.inspect})"
        end
        @attributes_list = normalize_attributes(attributes_list)
        @nested_attributes_to_assign = {}
        @dynabutee = dynabutee
      end

      def build_assignable_attributes
        desperados = [] # has_one params without :id key need special care
        collect_fields(@attributes_list)
        @attributes_list.each do |attrs|
          field = resolve_field(attrs)
          next if field.nil?
          next let_go(field, attrs) if field.has_many
          next let_go(field, attrs) if attrs[:id].present?
          desperados.push([attrs, field])
        end

        desperados
          .group_by { |(_, field)| field.value_type }
          .each do |value_type, attrs_fields| # for each value tables

          existing_values = @dynabutee.send(Util.value_relation_name(value_type))
                              .where(field_id: attrs_fields.map{|(_, f)| f.id})
                              .to_a # trying to reduce queries
          attrs_fields.each do |(attrs, field)| # for each attrs
            params = {
              id: existing_values.detect{|v| v.field_id == field.id}.try(:id),
              value: attrs[:value],
              field_id: field.id
            }
            let_go(field, params)
          end
        end
        yield(@nested_attributes_to_assign)
      end

      private

      def normalize_attributes(attributes_list)
        if attributes_list.is_a? Hash
          attributes_array = if attributes_list.keys.all?{|k| k =~ /\A\d+\Z/}
                              attributes_list.values
                            else
                              [attributes_list]
                       end
        else
          attributes_array = attributes_list
        end
        attributes_array.map{ |a| a.with_indifferent_access }
      end

      def resolve_field(attrs)
        @field_list.detect{|f| f.name == attrs[:name].to_s || f.id == attrs[:field_id].to_i}
      end

      def collect_fields(attrs)
        params = attrs.each_with_object({field_id: [], name: []}) do |a, memo|
          if a[:field_id] then memo[:field_id].push(a[:field_id])
          elsif a[:name] then memo[:name].push(a[:name])
          else fail FieldNotSpecified end
        end
        table = Dynabute::Field.arel_table
        @field_list = Dynabute::Field.for(@dynabutee.class.name)
          .where( table[:id].in(params[:field_id]).or(table[:name].in(params[:name])) )
      end

      def let_go(field, params)
        relation = Util.value_relation_name(field.value_type)
        (@nested_attributes_to_assign[relation] ||= []).push(params)
      end
    end

    module API
      extend ActiveSupport::Concern

      # - value: value
      # - (field_id || name): to identify the field
      # - id?:
      #   -- has_many: to determine create or update
      #   -- has_one: if the corresponding value record exists, will be added either way
      def dynabute_values_attributes=(attributes_list)
        Builder.new(attributes_list, self).build_assignable_attributes do |attributes|
          attributes.each do |relation, params|
            # this is a private method so can't call from inside Builder
            assign_nested_attributes_for_collection_association(relation, params)
          end
        end
      end
    end
  end
end
