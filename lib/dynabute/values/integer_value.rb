module Dynabute
  module Values
    class IntegerValue < ActiveRecord::Base
      include Dynabute::Values::Base
      belongs_to :option, class_name: "Dynabute::Option", foreign_key: 'value'
    end
  end
end
