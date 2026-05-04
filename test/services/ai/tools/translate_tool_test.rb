require "test_helper"

class Ai::Tools::TranslateToolTest < ActiveSupport::TestCase
  setup do
    @household = Household.create!(name: "TestHousehold")
    @user      = TelegramUser.create!(telegram_id: 9_700_001, household: @household)
    @context   = Ai::ToolContext.new(telegram_user: @user, chat_id: 1)
    @tool      = Ai::Tools::TranslateTool.new
  end

  def stub_mymemory(translated_text, status: 200)
    body = {
      "responseData"    => { "translatedText" => translated_text },
      "responseStatus"  => status,
      "responseDetails" => status == 200 ? "" : "Error"
    }.to_json

    response = Net::HTTPSuccess.new("1.1", "200", "OK")
    response.stub(:body, body) do
      Net::HTTP.stub(:get_response, response) do
        yield
      end
    end
  end

  test "translates text to target language" do
    stub_mymemory("manzana") do
      result = @tool.execute({ "text" => "apple", "target_language" => "es" }, @context)
      assert result.success
      assert_includes result.to_s, "manzana"
      assert_includes result.to_s, "apple"
    end
  end

  test "includes target language code in output" do
    stub_mymemory("Guten Tag") do
      result = @tool.execute({ "text" => "Good day", "target_language" => "de" }, @context)
      assert result.success
      assert_includes result.to_s, "DE"
    end
  end

  test "accepts explicit source language" do
    stub_mymemory("hello") do
      result = @tool.execute({ "text" => "hola", "target_language" => "en", "source_language" => "es" }, @context)
      assert result.success
      assert_includes result.to_s, "hello"
    end
  end

  test "raises when text is missing" do
    assert_raises(ArgumentError) { @tool.execute({ "target_language" => "es" }, @context) }
  end

  test "raises when target_language is missing" do
    assert_raises(ArgumentError) { @tool.execute({ "text" => "apple" }, @context) }
  end

  test "returns error on API failure" do
    response = Net::HTTPInternalServerError.new("1.1", "500", "Error")
    response.stub(:body, "{}") do
      Net::HTTP.stub(:get_response, response) do
        result = @tool.execute({ "text" => "apple", "target_language" => "es" }, @context)
        assert_not result.success
        assert_includes result.to_s, "Translation failed"
      end
    end
  end
end
