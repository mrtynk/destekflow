require "json"
require "net/http"

module Ai
  class OpenaiClient
    class Error < StandardError; end

    API_URI = URI("https://api.openai.com/v1/")

    def self.configured?
      ENV["OPENAI_API_KEY"].present?
    end

    def initialize(api_key: ENV["OPENAI_API_KEY"], timeout: 20)
      @api_key = api_key.to_s
      @timeout = timeout
      raise Error, "OPENAI_API_KEY yapılandırılmamış." if @api_key.blank?
    end

    def embeddings(inputs:, model:)
      response = post("embeddings", input: inputs, model:, encoding_format: "float")
      response.fetch("data").sort_by { |item| item.fetch("index") }.map { |item| item.fetch("embedding") }
    end

    def response(input:, instructions:, model:)
      payload = post("responses", input:, instructions:, model:, max_output_tokens: 220, store: false)
      payload.fetch("output").filter_map do |item|
        item["content"]&.filter_map { |content| content["text"] if content["type"] == "output_text" }&.join
      end.join("\n").presence || raise(Error, "OpenAI boş yanıt döndürdü.")
    end

    private

    def post(path, payload)
      uri = URI.join(API_URI, path)
      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(payload)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: @timeout, read_timeout: @timeout) do |http|
        http.request(request)
      end
      raise Error, "OpenAI isteği başarısız (HTTP #{response.code})." unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue JSON::ParserError, KeyError => error
      raise Error, "OpenAI yanıtı doğrulanamadı: #{error.class}."
    rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => error
      raise Error, "OpenAI bağlantısı kurulamadı: #{error.class}."
    end
  end
end
