module ActiveModel
  module Validations
    module JsonValidationHelper
      AVAILABLE_VALIDATOR_KEYS = [:absence, :acceptance, :exclusion, :format, :inclusion, :length, :presence, :hash, :array]

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

      # These two method are moved from ActiveModel::Validation#_validates_default_keys
      # We can't call immediately because there are protected method
      def _validates_default_keys
        [:if, :unless, :on, :allow_blank, :allow_nil , :strict]
      end

      def _parse_validates_options(options)
        case options
        when TrueClass
          {}
        when Hash
          options
        when Range, Array
          { in: options }
        else
          { with: options }
        end
      end
    end
  end
end