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
        describe 'finding values' do
          let!(:value) { Dynabute::Values::IntegerValue.create(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_field.id, value: 1)}
          it 'can find by field_id' do
            expect(user.dynabute_value(field_id: int_field.id).try(:value)).to eq(1)
          end
          it 'can find by name' do
            expect(user.dynabute_value(name: int_field.name).try(:value)).to eq(1)
            expect(user.dynabute_value(name: int_field.name.to_sym).try(:value)).to eq(1)
          end
          it 'can find by field' do
            expect(user.dynabute_value(field: int_field).try(:value)).to eq(1)
          end
          it 'raises ArgumentError when fetching value by invalid name argument' do
            expect{ user.dynabute_value(name: nil) }.to raise_error(ArgumentError)
            expect{ user.dynabute_value(name: '') }.to raise_error(ArgumentError)
            expect{ user.dynabute_value(name: 123) }.to raise_error(ArgumentError)
          end
          it 'raises ArgumentError when fetching value by invalid field_id argument' do
            expect{ user.dynabute_value(field_id: nil) }.to raise_error(ArgumentError)
            expect{ user.dynabute_value(field_id: '1') }.to raise_error(ArgumentError)
          end
          it 'raises ArgumentError when fetching value by invalid field argument' do
            expect{ user.dynabute_value(field: nil) }.to raise_error(ArgumentError)
            expect{ user.dynabute_value(field: {}) }.to raise_error(ArgumentError)
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

        context 'when unsaved association exists' do
          before { user.build_dynabute_value(field: int_field, value: 3) }
          it 'returns the unsaved association' do
            expect(user.dynabute_value(field: int_field).id).to be_nil
            expect(user.dynabute_value(field: int_field).value).to eq(3)
          end
        end

        it 'raises Dynabute::FieldNoFoundError when field not found' do
          expect{ user.dynabute_value(name: "I don't exist") }.to raise_error(Dynabute::FieldNotFound)
        end
      end

      context 'has many' do
        let!(:int_many_field) { Dynabute::Field.create(name: 'int many field', value_type: :integer, target_model: 'User', has_many: true) }
        context 'when value record exists' do
          let!(:values) { 2.times.map { Dynabute::Values::IntegerValue.create!(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_many_field.id, value: 1) } }
          subject { user.dynabute_value(name: 'int many field') }
          it 'returns values' do
            expect(subject).to be_a(Array)
            expect(subject.length).to eq(2)
          end
        end
        context 'when value record does not exist' do
          subject { user.dynabute_value(name: 'int many field') }
          it 'returns empty association' do
            expect(subject).to be_a(Array)
            expect(subject.length).to eq(0)
          end
        end

        context 'when unsaved association exists' do
          before { user.build_dynabute_value(field: int_many_field, value: 3) }
          it 'returns the unsaved association' do
            expect(user.dynabute_value(field: int_many_field).length).to eq(1)
            expect(user.dynabute_value(field: int_many_field).first.id).to be_nil
            expect(user.dynabute_value(field: int_many_field).first.value).to eq(3)
          end
          context 'saved record also exists' do
            let!(:existing_value){ Dynabute::Values::IntegerValue.create!(field_id: int_many_field.id, dynabutable_id: user.id, dynabutable_type: 'User', value: 1) }
            it 'returns both saved and unsaved records' do
              expect(user.dynabute_value(field: int_many_field).length).to eq(2)
              expect(user.dynabute_value(field: int_many_field).map(&:id)).to include(existing_value.id, nil)
            end
          end
        end
      end
    end

    describe '#get_dynabute_value' do
      context 'has one' do
        context 'when value record exists' do
          let!(:value) { Dynabute::Values::IntegerValue.create(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_field.id, value: 42)}
          it 'returns literal value found by field' do
            expect(user.get_dynabute_value(field: int_field)).to eq(42)
          end
          it 'returns literal value found by field name' do
            expect(user.get_dynabute_value(name: int_field.name)).to eq(42)
          end
          it 'returns literal value found by field id' do
            expect(user.get_dynabute_value(field_id: int_field.id)).to eq(42)
          end
        end
        context 'when value record does not exist' do
          it 'returns nil' do
            expect(user.get_dynabute_value(field: int_field)).to be_nil
          end
        end
      end
      context 'has_many' do
        let!(:int_many_field) { Dynabute::Field.create(name: 'int many field', value_type: :integer, target_model: 'User', has_many: true) }
        context 'when value records exist' do
          let!(:first_value) { Dynabute::Values::IntegerValue.create!(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_many_field.id, value: 1) }
          let!(:second_value) { Dynabute::Values::IntegerValue.create!(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_many_field.id, value: 2) }
          context 'value_id argument is not provided' do
            it 'returns array of literal values' do
              expect(user.get_dynabute_value(field: int_many_field)).to match_array([1, 2])
            end
          end
          context 'value_id argument is provided' do
            it 'returns literal value for given value record' do
              expect(user.get_dynabute_value(field: int_many_field, value_id: second_value.id)).to eq(2)
            end
          end
        end
        context 'when value records do not exist' do
          context 'value_id argument is not provided' do
            it 'returns empty array' do
              expect(user.get_dynabute_value(field: int_many_field)).to match_array([])
            end
          end
          context 'value_id argument is provided' do
            it 'returns nil' do
              expect(user.get_dynabute_value(field: int_many_field, value_id: 999)).to be_nil
            end
          end
        end
      end
    end
  end

  describe 'setting value' do
    let!(:user) { User.create }
    context 'has_one' do
      let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }
      context 'when value record does not exist' do
        subject { user.set_dynabute_value(field: int_field, value: 42) }
        it 'creates new unsaved association' do
          expect(subject).to be_a(Dynabute::Values::IntegerValue)
          expect(subject.attributes).to include({
            'field_id' => int_field.id,
            'dynabutable_type' => 'User',
            'dynabutable_id' => user.id,
            'value' => 42,
            'id' => nil
          })
          expect(subject.new_record?).to be true
        end
      end
      context 'when value record exists' do
        let!(:value) { Dynabute::Values::IntegerValue.create(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_field.id, value: 1)}
        subject { user.set_dynabute_value(field: int_field, value: 42) }
        it 'changes existing association without saving' do
          expect(subject).to be_a(Dynabute::Values::IntegerValue)
          expect(subject.attributes).to include({
            'field_id' => int_field.id,
            'dynabutable_type' => 'User',
            'dynabutable_id' => user.id,
            'value' => 42,
            'id' => value.id
          })
          expect(subject.persisted?).to be true
        end
      end
    end
    context 'has_many' do
      let!(:int_many_field) { Dynabute::Field.create(name: 'int many field', value_type: :integer, target_model: 'User', has_many: true) }
      context 'when value records do not exist' do
        context 'when value_id argument is not provided' do
          subject { user.set_dynabute_value(field: int_many_field, value: 42) }
          it 'creates new unsaved association' do
            expect(subject).to be_a(Dynabute::Values::IntegerValue)
            expect(subject.attributes).to include({
              'field_id' => int_many_field.id,
              'dynabutable_id' => user.id,
              'dynabutable_type' => 'User',
              'value' => 42,
              'id' => nil
            })
            expect(subject.new_record?).to be true
          end
        end
        context 'when value_id argument is provided' do
          subject { user.set_dynabute_value(field: int_many_field, value: 42, value_id: 999) }
          it 'raises ValueNotFound exception' do
            expect { subject }.to raise_error(Dynabute::Dynabutable::ValueNotFound)
          end
        end
      end
      context 'when value records exist' do
        let!(:first_value) { Dynabute::Values::IntegerValue.create!(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_many_field.id, value: 1) }
        let!(:second_value) { Dynabute::Values::IntegerValue.create!(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_many_field.id, value: 2) }
        context 'when value_id argument is not provided' do
          subject { user.set_dynabute_value(field: int_many_field, value: 42) }
          it 'created new unsaved association' do
            expect(subject).to be_a(Dynabute::Values::IntegerValue)
            expect(subject.attributes).to include({
              'field_id' => int_many_field.id,
              'dynabutable_type' => 'User',
              'dynabutable_id' => user.id,
              'value' => 42,
              'id' => nil
            })
            expect(subject.new_record?).to be true
          end
        end
        context 'when value_id argument is provided' do
          subject { user.set_dynabute_value(field: int_many_field, value: 42, value_id: second_value.id) }
          it 'changes existing association without saving' do
            expect(subject).to be_a(Dynabute::Values::IntegerValue)
            expect(subject.attributes).to include({
              'field_id' => int_many_field.id,
              'dynabutable_type' => 'User',
              'dynabutable_id' => user.id,
              'value' => 42,
              'id' => second_value.id
            })
            expect(subject.persisted?).to be true
          end
        end
      end
    end
  end

  describe 'deleting value' do
    let!(:user) { User.create }
    context 'has_one' do
      let!(:int_field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }
      context 'when value record exists' do
        let!(:value) { Dynabute::Values::IntegerValue.create(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_field.id, value: 1)}
        subject { user.remove_dynabute_value(field: int_field) }
        it 'returns deleted association' do
          expect(subject).to be_a(Dynabute::Values::IntegerValue)
          expect(subject.attributes).to include({
            'field_id' => value.field_id,
            'dynabutable_type' => value.dynabutable_type,
            'dynabutable_id' => value.dynabutable_id,
            'value' => value.value,
            'id' => value.id
          })
          expect(subject.destroyed?).to be true
        end
      end
      context 'when value record does not exist' do
        subject { user.remove_dynabute_value(field: int_field) }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end
    context 'has_many' do
      let!(:int_many_field) { Dynabute::Field.create(name: 'int many field', value_type: :integer, target_model: 'User', has_many: true) }
      context 'when value records exist' do
        let!(:first_value) { Dynabute::Values::IntegerValue.create!(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_many_field.id, value: 1) }
        let!(:second_value) { Dynabute::Values::IntegerValue.create!(dynabutable_id: user.id, dynabutable_type: 'User', field_id: int_many_field.id, value: 2) }
        context 'when value_id argument is not provided' do
          subject { user.remove_dynabute_value(field: int_many_field) }
          it 'returns array of deleted associations' do
            expect(subject).to all(be_a(Dynabute::Values::IntegerValue))
            expect(subject.map(&:destroyed?)).to all(be true)
          end
        end
        context 'when value_id argument is provided' do
          subject { user.remove_dynabute_value(field: int_many_field, value_id: second_value.id) }
          it 'returns deleted association' do
            expect(subject).to be_a(Dynabute::Values::IntegerValue)
            expect(subject.attributes).to include({
              'field_id' => second_value.field_id,
              'dynabutable_type' => second_value.dynabutable_type,
              'dynabutable_id' => second_value.dynabutable_id,
              'value' => second_value.value,
              'id' => second_value.id
            })
            expect(subject.destroyed?).to be true
          end
        end
      end
      context 'when value records do not exist' do
        subject { user.remove_dynabute_value(field: int_many_field) }
        it 'returns empty array' do
          expect(subject).to match_array([])
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
