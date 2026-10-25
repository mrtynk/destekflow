require "test_helper"

class GeminiClientTest < ActiveSupport::TestCase
  test "anahtar olmadan kapalı kalır" do
    assert_raises(Ai::GeminiClient::Error) { Ai::GeminiClient.new(api_key: nil) }
  end

  test "model adına url parçası enjekte edilmesini reddeder" do
    client = Ai::GeminiClient.new(api_key: "sahte-test-anahtari")

    assert_raises(Ai::GeminiClient::Error) do
      client.response(input: "test", instructions: "test", model: "gemini/../../yanlis")
    end
  end
end
