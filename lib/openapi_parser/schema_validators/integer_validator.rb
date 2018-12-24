class OpenAPIParser::SchemaValidator
  class IntegerValidator < Base
    include ::OpenAPIParser::SchemaValidator::Enumable

    def coerce_and_validate(value, schema)
      value = coerce(value) if @coerce_value

      return validator.validate_error(value, schema) unless value.kind_of?(Integer)

      check_enum_include(value, schema)
    end

    private

      def coerce(value)
        return value if value.kind_of?(Integer)

        begin
          return Integer(value)
        rescue ArgumentError => e
          raise e unless e.message =~ /invalid value for Integer/
        end

        value
      end
  end
end
