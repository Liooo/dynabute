module Dynabute::Values
  module Base
    extend ActiveSupport::Concern

    included do
      def self.table_name_prefix; 'dynabute_'; end
      belongs_to :dynabutable, polymorphic: true
      belongs_to :dynabute_field, class_name: 'Dynabute::Field'

      def value_type
        dynabute_field.value_type
      end
    end

  end

end
