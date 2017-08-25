require 'active_support/concern'
require 'dynabute/field'
require 'dynabute/dynabutable'
require 'dynabute/values'
require 'dynabute/option'

module Dynabute
  class FieldNotFound < StandardError
    def initialize(*criteria); @criteria = criteria; end
    def to_s; "No dynabute field #{@criteria.compact.first} found"; end
  end

  module ClassMethods
    def has_dynabutes
      include Dynabutable
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend Dynabute::ClassMethods
end
