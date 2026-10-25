require "json"
require "net/http"

module Ai
  class GeminiClient
    class Error < StandardError; end

    API_ROOT = "https://generativelanguage.googleapis.com/v1beta/models/"
    MODEL_NAME = /\A[a-zA-Z0-9._-]+\z/
    DEFAULT_OPEN_TIMEOUT = 10
    DEFAULT_READ_TIMEOUT = 60
    MAX_ATTEMPTS = 3
    RETRYABLE_STATUS_CODES = %w[429 500 502 503 504].freeze

    def self.configured?
      ENV["GEMINI_API_KEY"].present?
    end

    def initialize(
      api_key: ENV["GEMINI_API_KEY"],
      open_timeout: DEFAULT_OPEN_TIMEOUT,
      read_timeout: DEFAULT_READ_TIMEOUT
    )
      @api_key = api_key.to_s
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      raise Error, "GEMINI_API_KEY yapılandırılmamış." if @api_key.blank?
    end

    def embeddings(inputs:, model:)
      model = validate_model!(model)
      requests = inputs.map do |input|
        {
          model: "models/#{model}",
          content: { parts: [ { text: "Anlamsal destek talebi benzerliği için: #{input}" } ] },
          taskType: "SEMANTIC_SIMILARITY",
          outputDimensionality: 768
        }
      end
      response = post(model, "batchEmbedContents", requests:)
      response.fetch("embeddings").map { |embedding| embedding.fetch("values") }
    rescue Error => error
      raise Error, "Embedding aşaması: #{error.message}"
    end

    def response(input:, instructions:, model:)
      payload = post(
        validate_model!(model),
        "generateContent",
        system_instruction: { parts: [ { text: instructions } ] },
        contents: [ { role: "user", parts: [ { text: input } ] } ],
        generationConfig: {
          maxOutputTokens: 220,
          thinkingConfig: { thinkingLevel: "low" }
        }
      )
      payload.fetch("candidates").first.fetch("content").fetch("parts").filter_map { |part| part["text"] }.join("\n").presence ||
        raise(Error, "Gemini boş yanıt döndürdü.")
    rescue Error => error
      raise Error, "Üretim aşaması: #{error.message}"
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

      attempts = 0
      response = nil
      loop do
        attempts += 1
        response = Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: true,
          open_timeout: @open_timeout,
          read_timeout: @read_timeout
        ) do |http|
          http.request(request)
        end

        if RETRYABLE_STATUS_CODES.include?(response.code) && attempts < MAX_ATTEMPTS
          sleep(2**(attempts - 1))
          next
        end

        break
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
