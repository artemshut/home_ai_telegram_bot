module HomeAiTelegramBot
  module Ai
    module Tools
      class BaseTool
        def self.tool_name
          raise NotImplementedError, "#{name}.tool_name not implemented"
        end

        def self.description
          raise NotImplementedError, "#{name}.description not implemented"
        end

        def self.schema
          raise NotImplementedError, "#{name}.schema not implemented"
        end

        def self.definition
          { name: tool_name, description: description, input_schema: schema }
        end

        def execute(arguments, context)
          errors = JSON::Validator.fully_validate(self.class.schema, arguments)
          raise ArgumentError, errors.first if errors.any?

          call(arguments, context)
        end

        private

        def call(_arguments, _context)
          raise NotImplementedError, "#{self.class.name}#call not implemented"
        end
      end
    end
  end
end
