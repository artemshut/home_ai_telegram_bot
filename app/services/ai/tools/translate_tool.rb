module Ai
  module Tools
    class TranslateTool < BaseTool
      def self.tool_name = "translate"
      def self.description = <<~DESC
        Translate a word or phrase into another language.
        Use this whenever the user asks "how do you say X in Y" or "what is X in Y language".
        Pass the target_language as an ISO 639-1 code (e.g. "es" for Spanish, "fr" for French,
        "pl" for Polish, "de" for German, "uk" for Ukrainian). Detect the source language
        automatically by omitting source_language.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "text"            => { "type" => "string", "description" => "Word or phrase to translate" },
            "target_language" => { "type" => "string", "description" => "ISO 639-1 target language code (e.g. 'es', 'fr', 'de')" },
            "source_language" => { "type" => "string", "description" => "ISO 639-1 source language code (default: 'en')" }
          },
          "required" => [ "text", "target_language" ]
        }
      end

      private

      def call(arguments, _context)
        text   = arguments["text"].strip
        target = arguments["target_language"].strip.downcase
        source = arguments.fetch("source_language", "en").strip.downcase

        translation = fetch_translation(text, source, target)
        ToolResult.ok("\"#{text}\" in #{target.upcase}: #{translation}")
      rescue => e
        ToolResult.err("Translation failed: #{e.message}")
      end

      def fetch_translation(text, source, target)
        uri    = URI("https://api.mymemory.translated.net/get")
        params = URI.encode_www_form(q: text, langpair: "#{source}|#{target}")
        uri.query = params

        response = Net::HTTP.get_response(uri)
        raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        body = JSON.parse(response.body)
        raise body["responseDetails"] if body["responseStatus"].to_i != 200

        body.dig("responseData", "translatedText").presence || raise("Empty translation")
      end
    end
  end
end
