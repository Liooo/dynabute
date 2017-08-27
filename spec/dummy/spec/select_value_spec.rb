require './spec/dummy/spec/rails_helper'

RSpec.describe Dynabute::Values::SelectValue, type: :model do
  describe '#ensure_option_is_in_same_field' do
    let!(:select_field){ Dynabute::Field.create(name: 'select', value_type: 'select', target_model: 'User') }
    before {  Dynabute::Field.create(name: 'select2', value_type: 'select', target_model: 'User', options_attributes: [{label: 'heh'}]) }
    let!(:another_option) { Dynabute::Option.first }
    it 'works' do
      value = Dynabute::Values::SelectValue.create(field_id: select_field.id, value: another_option.id, dynabutable_type: 'User', dynabutable_id: 1)
      expect(value.errors[:value]).to be_present
    end
  end
end
