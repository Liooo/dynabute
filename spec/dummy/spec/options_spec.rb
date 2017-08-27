require './spec/dummy/spec/rails_helper'

RSpec.describe Dynabute::Option, type: :model do
  describe 'validation' do
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

  describe 'select' do
    let!(:select_field){ Dynabute::Field.create(name: 'select', value_type: 'select', target_model: 'User') }
    before { User.create.build_dynabute_value(name: 'select', value: select_field.id).save }
    it 'uses integer value' do
      expect(Dynabute::Values::IntegerValue.count).to eq(1)
    end

    describe '#option' do
      let(:user) { User.create }
      before do
        User.create.build_dynabute_value(name: 'select', value: select_field.id).save
      end

      it 'returns option' do
      end

    end
  end
end
