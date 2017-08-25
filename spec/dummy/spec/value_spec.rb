require './spec/dummy/spec/rails_helper'

RSpec.describe Dynabute::Values, type: :model do
  describe 'reading value' do
    let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }
    let!(:user) { User.create }

    describe '#dynabute_<field name>_value' do
      let!(:value) { Dynabute::Values::IntegerValue.create(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_field.id, value: 1)}
      it { expect(user.dynabute_int_field_value.value).to eq 1 }
      it { expect{ user.dynabute_unregistered_field_name_value }.to raise_error(NoMethodError) }
    end

    describe '#dynabute_value' do
      context 'has one' do
        context 'when value record exists' do
          let!(:value) { Dynabute::Values::IntegerValue.create(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_field.id, value: 1)}
          it 'returns value' do
            expect(user.dynabute_value(name: 'int field').try(:value)).to eq(1)
          end
        end

        context 'when value record does not exist' do
          it 'returns nil' do
            expect(user.dynabute_value(name: 'int field')).to be_nil
          end
        end

        it 'raises Dynabute::FieldNoFoundError when field not found' do
          expect{ user.dynabute_value(name: 'I dont exist') }.to raise_error(Dynabute::FieldNotFound)
        end
      end

      context 'has many' do
        let!(:int_many_field) { Dynabute::Field.create(name: 'int many field', value_type: :integer, target_model: 'User', has_many: true) }
        context 'when value record exists' do
          let!(:values) { 2.times.map { Dynabute::Values::IntegerValue.create!(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_many_field.id, value: 1) } }
          subject { user.dynabute_value(name: 'int many field') }
          it 'returns values' do
            expect(subject).to be_a(ActiveRecord::AssociationRelation)
            expect(subject.length).to eq(2)
          end
        end
        context 'when value record does not exist' do
          subject { user.dynabute_value(name: 'int many field') }
          it 'returns empty association' do
            expect(subject).to be_a(ActiveRecord::AssociationRelation)
            expect(subject.length).to eq(0)
          end
        end
      end
    end
  end

  describe '#build_dynabute_value' do
    let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }
    let!(:user) { User.create }
    subject { user.build_dynabute_value(field: int_field) }
    it 'builds' do
      expect(subject).to be_a(Dynabute::Values::IntegerValue)
      expect(subject.attributes).to include({'field_id' => int_field.id, 'dynabutable_id' => user.id, 'dynabutable_type' => 'User'})
    end
  end

  describe 'nested attributes' do

    describe 'has one' do
      let!(:user) { User.create(name: 'hello') }
      let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }

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

    describe 'has many' do
      let!(:user) { User.create(name: 'hello') }
      let!(:int_field) { Dynabute::Field.create!(name: 'int field', value_type: :integer, has_many: true, target_model: 'User') }
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
