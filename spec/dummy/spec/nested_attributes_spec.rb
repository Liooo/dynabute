require './spec/dummy/spec/rails_helper'

RSpec.describe Dynabute::NestedAttributes do
  let(:user) { User.create(name: 'hello') }

  describe '_destroy' do
    let!(:int_field) { Dynabute::Field.create!(name: 'int field', value_type: :integer, target_model: 'User', has_many: true) }
    let!(:destroyed_int) { Dynabute::Values::IntegerValue.create!(dynabutable_type: 'User', dynabutable_id: user.id, field_id: int_field.id, value: 1) }
    before { Dynabute::Values::IntegerValue.create!(dynabutable_type: 'User', dynabutable_id: user.id, field_id: int_field.id, value: 3) }
    let!(:attrs) { {dynabute_values_attributes: [{field_id: int_field.id, id: destroyed_int.id, _destroy: true}]} }
    it 'works' do
      expect{ user.update!(attrs) }.to change{ Dynabute::Values::IntegerValue.count }.from(2).to(1)
    end
  end

  context 'has params with empty value' do
    let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }
    let!(:another_int_field) { Dynabute::Field.create(name: 'another int field', value_type: :integer, target_model: 'User') }
    let!(:attrs) { {name: 'john', dynabute_values_attributes: [{field_id: int_field.id, value: 3}, {field_id: another_int_field.id, value: ''} ]} }
    it 'rejects empty valued ones' do
      user = User.new(attrs)
      expect(user.dynabute_values.count).to eq(1)
    end
  end

  describe 'indifferent accessed hash' do
    let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }

    context 'given symbol keyed hash' do
      let!(:attrs) { {dynabute_values_attributes: [ {field_id: int_field.id, value: 1}, ]} }
      it 'creates new record' do
        expect{ user.update!(attrs) }.to change{
          Dynabute::Values::IntegerValue.where(dynabutable_id: user.id, field_id: int_field.id, value: 1).count
        }.from(0).to(1)
      end
    end

    context 'given string keyed hash' do
      let!(:attrs) { {'dynabute_values_attributes' => [ {'field_id' => int_field.id, 'value' => 1}, ]} }
      it 'creates new record' do
        expect{ user.update!(attrs) }.to change{
          Dynabute::Values::IntegerValue.where(dynabutable_id: user.id, field_id: int_field.id, value: 1).count
        }.from(0).to(1)
      end
    end

    context 'given field_id value as string' do
      let!(:attrs) { {dynabute_values_attributes: [ {field_id: int_field.id.to_s, value: 1}, ]} }
      it 'creates new record' do
        expect{ user.update!(attrs) }.to change{
          Dynabute::Values::IntegerValue.where(dynabutable_id: user.id, field_id: int_field.id, value: 1).count
        }.from(0).to(1)
      end
    end

    context 'given symbol name as symbol' do
      let!(:attrs) { {dynabute_values_attributes: [ {name: int_field.name.to_sym, value: 1}, ]} }
      it 'creates new record' do
        expect{ user.update!(attrs) }.to change{
          Dynabute::Values::IntegerValue.where(dynabutable_id: user.id, field_id: int_field.id, value: 1).count
        }.from(0).to(1)
      end
    end

    context 'single hash attribute' do
      let!(:attrs) { {dynabute_values_attributes: {name: int_field.name.to_sym, value: 1} } }
      it 'creates new record' do
        expect{ user.update!(attrs) }.to change{
          Dynabute::Values::IntegerValue.where(dynabutable_id: user.id, field_id: int_field.id, value: 1).count
        }.from(0).to(1)
      end
    end

    context 'hash with numeric keys' do
      let!(:another_int_field) { Dynabute::Field.create!(name: 'another int field', value_type: :integer, target_model: 'User') }
      let!(:attrs) { {'dynabute_values_attributes' => { '0' => {name: int_field.name, value: 1}, '1' => {name: another_int_field.name, value: 1}} } }
      it 'handled as array' do
        expect{ user.update!(attrs) }.to change{
          Dynabute::Values::IntegerValue.where(dynabutable_id: user.id).count
        }.from(0).to(2)
      end
    end
  end

  describe 'has one' do
    let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }

    describe 'creating' do
      let!(:attrs) { {name: 'harry', dynabute_values_attributes: [{field_id: int_field.id, value: 1}]} }
      it 'creates' do
        User.create!(attrs)
        expect(User.count).to eq(1)
        expect(Dynabute::Values::IntegerValue.count).to eq(1)
      end
    end

    describe 'updating' do
      context 'value record do not exist' do
        let!(:attrs) { {dynabute_values_attributes: [ {field_id: int_field.id, value: 1}, ]} }
        it 'creates new record' do
          expect{ user.update!(attrs) }.to change{
            Dynabute::Values::IntegerValue.where(dynabutable_id: user.id, field_id: int_field.id, value: 1).count
          }.from(0).to(1)
        end
      end

      context 'value record exists' do
        let!(:int_value) { Dynabute::Values::IntegerValue.create(dynabutable_type: 'User', dynabutable_id: user.id, field_id: int_field.id, value: 1) }
        let!(:attrs) { {dynabute_values_attributes: [ {field_id: int_field.id, value: 3}, ]} }
        subject { user.update!(attrs) }
        it { expect{ subject }.not_to change{ Dynabute::Values::IntegerValue.count } }
        it { expect{ subject }.to change{ int_value.reload.value }.to(3) }
      end
    end
  end

  describe 'has many' do
    let!(:int_field) { Dynabute::Field.create!(name: 'int field', value_type: :integer, has_many: true, target_model: 'User') }

    describe 'creating' do
      let!(:attrs) { {name: 'harry', dynabute_values_attributes: [{field_id: int_field.id, value: 1}, {field_id: int_field.id, value: 2}]} }
      it 'creates' do
        User.create!(attrs)
        expect(User.count).to eq(1)
        expect(Dynabute::Values::IntegerValue.count).to eq(2)
      end
    end

    describe 'updating' do
      context 'without id' do
        let!(:attrs) { {dynabute_values_attributes: [ {field_id: int_field.id, value: 1}, {field_id: int_field.id, value: 2}]} }
        it 'creates new record' do
          expect{ user.update!(attrs) }.to change {
            Dynabute::Values::IntegerValue.where(dynabutable_id: user.id, field_id: int_field.id).count
          }.from(0).to(2)
        end
      end
      context 'updating existing' do
        let!(:existing) { Dynabute::Values::IntegerValue.create!(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_field.id, value: 0) }
        let!(:attrs) { {dynabute_values_attributes: [ {id: existing.id, field_id: int_field.id, value: 1} ]} }
        it 'does not create new record' do
          expect{ user.update!(attrs) }.to_not change {
            Dynabute::Values::IntegerValue.where(dynabutable_id: user.id, field_id: int_field.id).count
          }
        end
        it 'updates value' do
          expect{ user.update!(attrs) }.to change {
            Dynabute::Values::IntegerValue.find_by(dynabutable_id: user.id, field_id: int_field.id).value
          }.to(1)
        end
      end
    end
  end
end
