class CreateDynabutes < ActiveRecord::Migration[5.1]
  def change
    create_table "dynabute_fields", force: :cascade do |t|
      t.string   "name", limit: 50
      t.string   "value_type", limit: 15
      t.boolean  "has_many", default: false
      t.string   "target_model", limit: 50
    end
    add_index "dynabute_fields", ["target_model", "name"], name: "index_dynabute_fields_on_target_model_and_name", using: :btree

    create_table "dynabute_string_values", force: :cascade do |t|
      t.integer  "field_id", limit: 4
      t.integer  "dynabutable_id", limit: 4
      t.string   "dynabutable_type", limit: 50
      t.string   "value", limit: 255
    end
    add_index "dynabute_string_values", ["dynabutable_id"], name: "dynabute_string_values_on_recordable_id", using: :btree
    add_index "dynabute_string_values", ["dynabutable_id", "field_id"], name: "dynabute_string_values_on_record_id_and_recordable_id", using: :btree

    create_table "dynabute_integer_values", force: :cascade do |t|
      t.integer  "field_id", limit: 4
      t.integer  "dynabutable_id", limit: 4
      t.string   "dynabutable_type", limit: 50
      t.integer  "value"
    end
    add_index "dynabute_integer_values", ["dynabutable_id"], name: "dynabute_integer_values_on_recordable_id", using: :btree
    add_index "dynabute_integer_values", ["dynabutable_id", "field_id"], name: "dynabute_integer_values_on_record_id_and_recordable_id", using: :btree

    create_table "dynabute_boolean_values", force: :cascade do |t|
      t.integer  "field_id", limit: 4
      t.integer  "dynabutable_id", limit: 4
      t.string   "dynabutable_type", limit: 50
      t.boolean  "value"
    end
    add_index "dynabute_boolean_values", ["dynabutable_id"], name: "dynabute_boolean_values_on_recordable_id", using: :btree
    add_index "dynabute_boolean_values", ["dynabutable_id", "field_id"], name: "dynabute_boolean_values_on_record_id_and_recordable_id", using: :btree

    create_table "dynabute_datetime_values", force: :cascade do |t|
      t.integer  "field_id", limit: 4
      t.integer  "dynabutable_id", limit: 4
      t.string   "dynabutable_type", limit: 50
      t.boolean  "value"
    end
    add_index "dynabute_datetime_values", ["dynabutable_id"], name: "dynabute_datetime_values_on_recordable_id", using: :btree
    add_index "dynabute_datetime_values", ["dynabutable_id", "field_id"], name: "dynabute_datetime_values_on_record_id_and_recordable_id", using: :btree
  end

  create_table "dynabute_select_values", force: :cascade do |t|
    t.integer  "field_id", limit: 4
    t.integer  "dynabutable_id", limit: 4
    t.string   "dynabutable_type", limit: 50
    t.integer  "value"
  end
  add_index "dynabute_select_values", ["dynabutable_id"], name: "dynabute_select_values_on_recordable_id", using: :btree
  add_index "dynabute_select_values", ["dynabutable_id", "field_id"], name: "dynabute_select_values_on_record_id_and_recordable_id", using: :btree

  create_table "dynabute_options", force: :cascade do |t|
    t.integer "field_id", limit: 4
    t.string "label"
    t.index ["field_id"], name: "index_dynabute_options_on_field_id"
  end
end
