module Ai
  ToolResult = Struct.new(:success, :data, :error, keyword_init: true) do
    def self.ok(data)
      new(success: true, data: data)
    end

    def self.err(message)
      new(success: false, error: message)
    end

    def to_s
      success ? data.to_s : "Error: #{error}"
    end
  end
end
