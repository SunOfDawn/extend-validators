require 'extend-validators/validations'

module ActiveModel
  module Validations
    class ArrayValidator < EachValidator
      include JsonValidationHelper

      attr_accessor :validators, :default_options

      def initialize(options)
        super
        init_sub_validators
      end

      def init_sub_validators
        @validators = {}
        @default_options = filter_options(options)
        @default_options[:validates_each].to_a.each do |key, sub_options|
          next unless sub_options
          attributes.each do |attribute|
            parse_sub_options = parse_options(sub_options, attribute)
            @validators[validator_key(attribute, nil, parse_sub_options)] = get_validator(key).new(parse_sub_options)
          end
        end
      end

      # with array format value, you can use basic validator keywords validate every member like use in model,
      # such as:
      #
      #  class Person < ActiveRecord::Base
      #    validates :other, array: {
      #      validates_each: {
      #        numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
      #      }
      #    }, allow_nil: true
      #
      # with each member, you can use [:allow_nil :allow_blank] to check null,
      # but not support other conditions such as [:if, :on, :unless],
      # these condition only can use in root attribute.
      def validate_each(record, attribute, values)
        return record.errors.add(attribute, options[:message] || :invalid_array_value) unless values.is_a?(Array)

        values.each do |value|
          default_options[:validates_each].to_a.each do |key, sub_options|
            next if (sub_options[:allow_nil] && value.nil?) || (sub_options[:allow_blank] && value.blank?)
            validator_key = validator_key(attribute, nil, parse_options(sub_options, attribute))
            validators[validator_key].validate_each(record, attribute, value)
          end
        end
      end
    end

    module HelperMethods
      # Validates that the specified attribute matches the json context with your options
      # basic usage like to other active model, for example:
      #
      #   class Person < ActiveRecord::Base
      #     validates_array_of :json_value, {
      #       validates_each: {
      #         numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
      #       }
      #     }, allow_nil: true
      #   end
      #
      # Configuration options:
      # * <tt>:validates_each</tt> Specifies each value must be format with your sub options.
      # * <tt>:message</tt> - Specifies a custom error message, but only show when checking
      #   value format invalid (default is: "is not included in the list").
      #
      # There is also two of default options supported by every validator:
      # +:allow_nil+, +:allow_blank+
      # See <tt>ActiveModel::Validation#validates</tt> for more information
      #
      def validates_array_of(*attr_names)
        validates_with ArrayValidator, _merge_attributes(attr_names)
      end
    end
  end
end
