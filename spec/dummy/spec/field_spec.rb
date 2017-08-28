require './spec/dummy/spec/rails_helper'

RSpec.describe Dynabute, type: :model do
  describe 'Model.dynabutes' do
    let(:field) { Dynabute::Field.create(name: 'int field', value_type: :integer, target_model: 'User') }
    it 'works' do
      expect(User.dynabutes).to eq [field]
    end
  end

  describe 'Model.dynabutes <<' do
    it 'works' do
      expect { User.dynabutes << Dynabute::Field.new(name: 'int field', value_type: :integer) }.to(
        change{ Dynabute::Field.where(target_model: User.to_s).count }.from(0).to(1)
      )
    end
  end

  describe 'Model.dynabute_relation_names' do
    it 'returns relations' do
      expect(User.dynabute_relation_names).to eq(%i(string_values integer_values boolean_values datetime_values select_values))
    end
  end

  # describe 'joining' do
  #   let(:field1) { Dynabute::Field.create!(name: 'int field', value_type: :integer, target_model: 'User') }
  #   let(:field2) { Dynabute::Field.create!(name: 'int field2', value_type: :integer, target_model: 'User') }
  #   let(:field3) { Dynabute::Field.create!(name: 'int field3', value_type: :integer, target_model: 'User') }
  #   before do
  #     3.times{|n| User.create(dynabute_values_attributes: [
  #       {field_id: field1.id, value: 0},
  #       {field_id: field2.id, value: n},
  #       {field_id: field3.id, value: 0}
  #     ])}
  #   end
  #   it 'sorts well' do
  #     ids = User.join_to_fields([field1, field2]).order("integer_#{field1.id}.value desc, integer_#{field2.id}.value desc").map(&:id)
  #     expect(ids).to eq([3,2,1])
  #   end
  # end
end
