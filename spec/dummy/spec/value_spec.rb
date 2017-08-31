require './spec/dummy/spec/rails_helper'

RSpec.describe Dynabute::Dynabutable, type: :model do
  describe 'validation' do
    context 'creating multiple values for has_one field' do
      let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }
      let!(:user) { User.create }
      before { user.build_dynabute_value(field_id: int_field.id, value: 1).save! }
      it 'does not save' do
        expect{ user.build_dynabute_value(field_id: int_field.id, value: 1).save }.to_not change{ Dynabute::Values::IntegerValue.count }
      end
      it 'adds error' do
        value = user.build_dynabute_value(field_id: int_field.id, value: 1)
        value.save
        expect(value.errors[:base]).to be_present
      end
    end
  end

  describe 'reading value' do
    let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }
    let!(:user) { User.create }

    describe '#dynabute_<field name>_value' do
      let!(:value) { Dynabute::Values::IntegerValue.create(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_field.id, value: 1)}
      it { expect(user.dynabute_int_field_value.value).to eq 1 }
      it { expect{ user.dynabute_unregistered_field_name_value }.to raise_error(NoMethodError) }
    end

    describe '#build_dynabute_value' do
      context 'has one' do
        subject { user.build_dynabute_value(field_id: int_field.id, value: 3) }
        it 'can build' do
          expect(subject).to be_a Dynabute::Values::IntegerValue
          expect(subject.new_record?).to eq(true)
          expect(subject.slice(:id, :field_id, :dynabutable_type, :value)).to eq({'id' => nil, 'field_id' => int_field.id, 'dynabutable_type' => 'User', 'value' => 3})
        end
      end
    end

    describe '#dynabute_value' do
      context 'has one' do
        context 'finding values' do
          let!(:value) { Dynabute::Values::IntegerValue.create(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_field.id, value: 1)}
          it 'can find by field_id' do
            expect(user.dynabute_value(field_id: int_field.id).try(:value)).to eq(1)
          end
          it 'can find by name' do
            expect(user.dynabute_value(name: int_field.name).try(:value)).to eq(1)
          end
          it 'can find by field' do
            expect(user.dynabute_value(field: int_field).try(:value)).to eq(1)
          end
        end

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

end
