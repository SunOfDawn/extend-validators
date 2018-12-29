require 'extend-validators/validations'

module ActiveModel
  module Validations
    class HashValidator < EachValidator
      include JsonValidationHelper

      attr_accessor :validators, :default_options

      def initialize(options)
        super
        init_sub_validators
      end

      def init_sub_validators
        @validators = {}
        @default_options = filter_options(options)
        @default_options.each do |members, member_options|
          filter_options(member_options).each do |key, sub_options|
            next unless sub_options
            attributes.each do |attribute|
              parse_sub_options = parse_options(sub_options, attribute)
              @validators[validator_key(attribute, members, parse_sub_options)] = get_validator(key).new(parse_sub_options)
            end
          end
        end
      end

      # with hash format value, you can use basic validator keywords validate every member like use in model,
      # such as:
      #
      #  class Person < ActiveRecord::Base
      #    validates :other, hash: {
      #      name: { presence: true },
      #      age: { numericality: { only_integer: true, greater_than: 0 } },
      #      [:height, :weight] => { numericality: { only_integer: true, greater_than: 0 } },
      #      description: { format: { with: /.*/ }, allow_blank: true }
      #    }, allow_nil: true
      #
      # With each member, you can use [:allow_nil :allow_blank] to check null,
      # but not support other conditions such as [:if, :on, :unless].
      # These will make the validation complex and difficult to read.
      # We recommend that only use these in model attribute
      def validate_each(record, attribute, value)
        return record.errors.add(attribute, options[:message] || :invalid_hash_value) unless value.is_a?(Hash)

        default_options.each do |members, sub_options|
          Array(members).each do |member|
            member_value = value[member]
            next if (sub_options[:allow_nil] && member_value.nil?) || (sub_options[:allow_blank] && member_value.blank?)

            filter_options(sub_options).each do |key, options|
              validator_key = validator_key(attribute, members, parse_options(options, attribute))
              validate_each_member(record, attribute, validators[validator_key], member, member_value)
            end
          end
        end
      end

      def validate_each_member(record, attribute, validator, member, member_value)
        before_errors_count = record.errors[attribute].count || 0
        validator.validate_each(record, attribute, member_value)
        after_errors_count = record.errors[attribute].count || 0
        record.errors[attribute][-1].insert(0, "#{member} ") if after_errors_count - before_errors_count > 0
      end
    end

    module HelperMethods
      # Validates that the specified attribute matches the json context with your options
      # basic usage like to other active model, for example:
      #
      #   class Person < ActiveRecord::Base
      #     validates_hash_of :json_value, {
      #       name: { presence: true },
      #       age: { numericality: { only_integer: true, greater_than: 0 } },
      #       [:height, :weight] => { numericality: { only_integer: true, greater_than: 0 } },
      #       description: { format: { with: /.*/ }, allow_blank: true }
      #   }
      #   end
      #
      # Configuration options:
      # * <tt>:message</tt> - Specifies a custom error message, but only show when checking
      #   value format invalid (default is: "is not included in the list").
      #
      # There is also two of default options supported by every validator:
      # +:allow_nil+, +:allow_blank+
      # See <tt>ActiveModel::Validation#validates</tt> for more information
      #
      def validates_hash_of(*attr_names)
        validates_with HashValidator, _merge_attributes(attr_names)
      end
    end
  end
end
