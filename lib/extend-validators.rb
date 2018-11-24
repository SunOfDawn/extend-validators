require 'extend-validators/validations/json_validator'
require 'extend-validators/validations/json_numericality_validator'
require 'active_support/core_ext/object/deep_dup'

ActiveSupport.on_load(:i18n) do
  I18n.load_path.concat Dir[File.dirname(__FILE__) + '/extend-validators/locale/*.yml']
end