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

  test "yalnız geçici HTTP durumlarını sınırlı sayıda yeniden dener" do
    assert_equal 3, Ai::GeminiClient::MAX_ATTEMPTS
    assert_includes Ai::GeminiClient::RETRYABLE_STATUS_CODES, "503"
    refute_includes Ai::GeminiClient::RETRYABLE_STATUS_CODES, "400"
    refute_includes Ai::GeminiClient::RETRYABLE_STATUS_CODES, "401"
  end

  test "başarılı HTTP yanıtını döngü sonrasında işler" do
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.instance_variable_set(:@read, true)
    response.body = '{"ok":true}'
    http_start = ->(*, **, &) { response }
    client = Ai::GeminiClient.new(api_key: "sahte-test-anahtari", http_start:)

    result = client.send(:post, "gemini-3.5-flash-lite", "generateContent", contents: [])

    assert_equal true, result.fetch("ok")
  end
end
