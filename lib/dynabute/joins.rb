module Dynabute
  module Joins
    module Field
      extend ActiveSupport::Concern
      def joined_alias
        "#{value_type}_#{id}"
      end

    end

    module Dynabutable
      extend ActiveSupport::Concern
      module ClassMethods
        def join_to_fields(fields)
          fields.inject(self) do |me, field|
            me.joins(join_source_for_field(field))
          end
        end

        private
        def join_source_for_field(field)
          value_table = field.value_class.arel_table.alias(field.joined_alias)
          dynabutee_table
            .join(value_table, Arel::Nodes::OuterJoin)
            .on(
              dynabutee_table[:id].eq(value_table[:dynabutable_id]).and(
              value_table[:dynabutable_type].eq(self.to_s)).and(
              value_table[:field_id].eq(field.id))
            ).join_sources
        end

        def dynabutee_table
          arel_table
        end
      end
    end
  end
end
