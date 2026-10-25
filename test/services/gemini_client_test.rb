require "test_helper"

class GeminiClientTest < ActiveSupport::TestCase
  test "anahtar olmadan kapalı kalır" do
    assert_raises(Ai::GeminiClient::Error) { Ai::GeminiClient.new(api_key: nil) }
  end

  test "model adına url parçası enjekte edilmesini reddeder" do
    client = Ai::GeminiClient.new(api_key: "sahte-test-anahtari")

    error = assert_raises(Ai::GeminiClient::Error) do
      client.response(input: "test", instructions: "test", model: "gemini/../../yanlis")
    end

    assert_match "Üretim aşaması", error.message
  end

  test "uzun model yanıtları için bağlantı ve okuma zaman aşımını ayırır" do
    client = Ai::GeminiClient.new(api_key: "sahte-test-anahtari")

    assert_equal 10, client.instance_variable_get(:@open_timeout)
    assert_equal 60, client.instance_variable_get(:@read_timeout)
  end
end
