module ActiveModel
  module Validations
    class JsonNumericalityValidator < NumericalityValidator
      # active model numericality validator will check the value changed before validate
      # but it can't read member in json, need rewrite this method
      def validate_each(record, attr_name, value)
        raw_value = value

        return if options[:allow_nil] && raw_value.nil?

        unless value = parse_raw_value_as_a_number(raw_value)
          record.errors.add(attr_name, :not_a_number, filtered_options(raw_value))
          return
        end

        if allow_only_integer?(record)
          unless value = parse_raw_value_as_an_integer(raw_value)
            record.errors.add(attr_name, :not_an_integer, filtered_options(raw_value))
            return
          end
        end

        options.slice(*CHECKS.keys).each do |option, option_value|
          case option
          when :odd, :even
            unless value.to_i.send(CHECKS[option])
              record.errors.add(attr_name, option, filtered_options(value))
            end
          else
            case option_value
            when Proc
              option_value = option_value.call(record)
            when Symbol
              option_value = record.send(option_value)
            end

            unless value.send(CHECKS[option], option_value)
              record.errors.add(attr_name, option, filtered_options(value).merge!(count: option_value))
            end
          end
        end
      end
    end
  end
end
