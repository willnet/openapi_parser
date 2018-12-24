require_relative 'schema_validators/options'
require_relative 'schema_validators/enumable'
require_relative 'schema_validators/base'
require_relative 'schema_validators/string_validator'
require_relative 'schema_validators/integer_validator'
require_relative 'schema_validators/float_validator'
require_relative 'schema_validators/boolean_validator'
require_relative 'schema_validators/object_validator'
require_relative 'schema_validators/array_validator'
require_relative 'schema_validators/any_of_validator'
require_relative 'schema_validators/nil_validator'

class OpenAPIParser::SchemaValidator
  class ValidatorOption
  end

  class << self
    # @param [Hash] value
    # @param [OpenAPIParser::Schemas::Schema]
    # @param [OpenAPIParser::SchemaValidator::Options] options
    # @return [Object] coerced or original params
    def validate(value, schema, options)
      new(value, schema, options).validate_data
    end
  end

  # @param [Hash] value
  # @param [OpenAPIParser::Schemas::Schema] schema
  # @param [OpenAPIParser::SchemaValidator::Options] options
  def initialize(value, schema, options)
    @value = value
    @schema = schema
    @coerce_value = options.coerce_value
    @datetime_coerce_class = options.datetime_coerce_class
  end

  # @return [Object] coerced or original params
  def validate_data
    coerced, err = validate_schema(@value, @schema)
    raise err if err

    coerced
  end

  def validate_error(value, schema)
    [nil, OpenAPIParser::ValidateError.new(value, schema.type, schema.object_reference)]
  end

  def validate_string(value, schema)
    (@string_validator ||= OpenAPIParser::SchemaValidator::StringValidator.new(self, @coerce_value, @datetime_coerce_class)).coerce_and_validate(value, schema)
  end

  def validate_integer(value, schema)
    (@integer_validator ||= OpenAPIParser::SchemaValidator::IntegerValidator.new(self, @coerce_value)).coerce_and_validate(value, schema)
  end

  def validate_float(value, schema)
    (@float_validator ||= OpenAPIParser::SchemaValidator::FloatValidator.new(self, @coerce_value)).coerce_and_validate(value, schema)
  end

  def validate_boolean(value, schema)
    (@boolean_validator ||= OpenAPIParser::SchemaValidator::BooleanValidator.new(self, @coerce_value)).coerce_and_validate(value, schema)
  end

  def validate_object(value, schema)
    (@object_validator ||= OpenAPIParser::SchemaValidator::ObjectValidator.new(self, @coerce_value)).coerce_and_validate(value, schema)
  end

  def validate_array(value, schema)
    (@array_validator ||= OpenAPIParser::SchemaValidator::ArrayValidator.new(self, @coerce_value)).coerce_and_validate(value, schema)
  end

  def validate_any_of(value, schema)
    (@any_of_validator ||= OpenAPIParser::SchemaValidator::AnyOfValidator.new(self, @coerce_value)).coerce_and_validate(value, schema)
  end

  def validate_nil(value, schema)
    (@nil_validator ||= OpenAPIParser::SchemaValidator::NilValidator.new(self, @coerce_value)).coerce_and_validate(value, schema)
  end

  # @param [Object] value
  # @param [OpenAPIParser::Schemas::Schema] schema
  def validate_schema(value, schema)
    return [value, nil] unless schema # no schema

    return validate_any_of(value, schema) if schema.any_of

    return validate_nil(value, schema) if value.nil?

    case schema.type
    when 'string'
      return validate_string(value, schema)
    when 'integer'
      return validate_integer(value, schema)
    when 'boolean'
      return validate_boolean(value, schema)
    when 'number'
      return validate_float(value, schema)
    when 'object'
      return validate_object(value, schema)
    when 'array'
      return validate_array(value, schema)
    else # rubocop:disable Style/EmptyElse
      # TODO: unknown type support
    end

    validate_error(value, schema)
  end
end
