require "json"
require "net/http"

module Ai
  class GeminiClient
    class Error < StandardError; end

    API_ROOT = "https://generativelanguage.googleapis.com/v1beta/models/"
    MODEL_NAME = /\A[a-zA-Z0-9._-]+\z/

    def self.configured?
      ENV["GEMINI_API_KEY"].present?
    end

    def initialize(api_key: ENV["GEMINI_API_KEY"], timeout: 20)
      @api_key = api_key.to_s
      @timeout = timeout
      raise Error, "GEMINI_API_KEY yapılandırılmamış." if @api_key.blank?
    end

    def embeddings(inputs:, model:)
      model = validate_model!(model)
      requests = inputs.map do |input|
        {
          model: "models/#{model}",
          content: { parts: [ { text: "Anlamsal destek talebi benzerliği için: #{input}" } ] }
        }
      end
      response = post(model, "batchEmbedContents", requests:)
      response.fetch("embeddings").map { |embedding| embedding.fetch("values") }
    end

    def response(input:, instructions:, model:)
      payload = post(
        validate_model!(model),
        "generateContent",
        system_instruction: { parts: [ { text: instructions } ] },
        contents: [ { role: "user", parts: [ { text: input } ] } ],
        generationConfig: { maxOutputTokens: 220, temperature: 0.2 }
      )
      payload.fetch("candidates").first.fetch("content").fetch("parts").filter_map { |part| part["text"] }.join("\n").presence ||
        raise(Error, "Gemini boş yanıt döndürdü.")
    end

    private

    def validate_model!(model)
      value = model.to_s
      raise Error, "Gemini model adı geçersiz." unless MODEL_NAME.match?(value)

      value
    end

    def post(model, method, payload)
      uri = URI("#{API_ROOT}#{model}:#{method}")
      request = Net::HTTP::Post.new(uri)
      request["x-goog-api-key"] = @api_key
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(payload)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: @timeout, read_timeout: @timeout) do |http|
        http.request(request)
      end
      raise Error, "Gemini isteği başarısız (HTTP #{response.code})." unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue JSON::ParserError, KeyError => error
      raise Error, "Gemini yanıtı doğrulanamadı: #{error.class}."
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => error
      raise Error, "Gemini bağlantısı kurulamadı: #{error.class}."
    end
  end
end
