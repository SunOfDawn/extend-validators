module ActiveModel
  module Validations
    class JsonValidator < EachValidator
      attr_accessor :validators, :default_options

      AVAILABLE_VALIDATOR_KEYS = [:absence, :acceptance, :exclusion, :format, :inclusion, :length, :presence, :json]

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

      # Only support base active model validator and json validator
      # validate every member like use in model, such as:
      #
      #  class Person < ActiveRecord::Base
      #    validates :other, json: {
      #      name: { presence: true },
      #      age: { numericality: { only_integer: true, greater_than: 0 } },
      #      [:height, :weight] => { numericality: { only_integer: true, greater_than: 0 } },
      #      description: { format: { with: /.*/ }, allow_blank: true }
      #    }, presence: true
      #
      # With each member, you can use [:allow_nil :allow_blank] to check null,
      # but not support other conditions such as [:if, :on, :unless].
      # These will make the validation complex and difficult to read.
      # We recommend that only use these in model attribute
      def validate_each(record, attribute, value)
        return record.errors.add(attribute, options[:message] || :invalid_json_value) unless value.is_a?(Hash)

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

      # All validate keywords base to activemodel validations, but can't init numericality validation directly.
      # Numericality validation method 'before_type_cast' can't read json member value.
      def get_validator(key)
        if AVAILABLE_VALIDATOR_KEYS.include?(key)
          "ActiveModel::Validations::#{key.to_s.camelize}Validator".constantize
        elsif :numericality == key
          ActiveModel::Validations::JsonNumericalityValidator
        else
          raise NameError, "Unknown validator: '#{key}'"
        end
      end

      def validator_key(attribute, members, options)
        "#{attribute}-#{Array(members).join('-')}-#{options}".hash
      end

      def filter_options(options)
        options.deep_dup.slice!(*_validates_default_keys)
      end

      def parse_options(options, attribute)
        _parse_validates_options(options).merge(attributes: attribute)
      end

      def _validates_default_keys
        [:if, :unless, :on, :allow_blank, :allow_nil, :strict]
      end

      def _parse_validates_options(options)
        case options
        when TrueClass
          {}
        when Hash
          options
        when Range, Array
          {in: options}
        else
          {with: options}
        end
      end
    end

    module HelperMethods
      # Validates that the specified attribute matches the json context with your options
      # basic usage like to other active model, for example:
      #
      #   class Person < ActiveRecord::Base
      #     validates_json_of :json_value, {
      #       name: { presence: true },
      #       age: { numericality: { only_integer: true, greater_than: 0 } },
      #       [:height, :weight] => { numericality: { only_integer: true, greater_than: 0 } },
      #       description: { format: { with: /.*/ }, allow_blank: true }
      #   }
      #   end
      #
      def validates_json_of(*attr_names)
        validates_with JsonValidator, _merge_attributes(attr_names)
      end
    end
  end
end
