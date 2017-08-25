module Dynabute
  class Option < ActiveRecord::Base
    belongs_to :dynabute_field, class_name: 'Dynabute::Field'
    validates_presence_of :label
  end
end
