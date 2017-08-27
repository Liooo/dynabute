require './spec/dummy/spec/rails_helper'

RSpec.describe Dynabute::Option, type: :model do
  describe 'validation' do
    describe 'uniqueness of label' do
      let!(:field) { Dynabute::Field.create(name: 'field', value_type: 'select', target_model: 'User') }
      before { Dynabute::Option.create(field_id: field.id, label: 'hey') }
      it 'works' do
        expect(Dynabute::Option.create(field_id: field.id, label: 'hey').errors[:label]).to be_present
      end
    end

    describe 'presence of field_id' do
      it 'validates presence of field_id' do
        expect(Dynabute::Option.create(label: 'aha').errors[:field_id]).to be_present
      end

      context 'nested attributes from Field' do
        it 'does not raise error' do
          expect(Dynabute::Field.create(
            name: 'select', value_type: :select, target_model: 'Test',
            options_attributes: [{label: 'hey'}]
          ).errors).to be_empty
        end
      end
    end
  end
end
