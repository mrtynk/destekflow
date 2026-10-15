# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

SOURCE_URL = "https://fortune.com/ranking/fortune500/"
MARKET_VALUE_FIELD = "Market Value ($M)"

response = Net::HTTP.get_response(URI(SOURCE_URL), { "User-Agent" => "DestekFlow academic audit" })
abort "Fortune isteği başarısız: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

payload = response.body.match(%r{<script id="__NEXT_DATA__" type="application/json">(.*?)</script>}m)
abort "__NEXT_DATA__ bulunamadı; Fortune sayfa yapısı değişmiş olabilir." unless payload

items = JSON.parse(payload[1]).dig("props", "pageProps", "franchiseSearch", "items")
abort "Fortune sıralama satırları bulunamadı." unless items.is_a?(Array)

fortune_500 = items.select { |item| item.fetch("rank").to_i.between?(1, 500) }
abort "Beklenen 500 satır yerine #{fortune_500.length} satır bulundu." unless fortune_500.length == 500

usable, missing = fortune_500.partition do |item|
  item.dig("data", MARKET_VALUE_FIELD).to_s.match?(%r{\A\$[\d,.]+\z})
end

rows = usable.map do |item|
  raw = item.dig("data", MARKET_VALUE_FIELD)
  {
    rank: item.fetch("rank").to_i,
    name: item.fetch("name"),
    raw: raw,
    value_millions: Float(raw.delete("$,")),
    url: URI.join(SOURCE_URL, item.fetch("slug")).to_s
  }
end

minimum, maximum = rows.minmax_by { |row| row.fetch(:value_millions) }

puts "Kaynak: #{SOURCE_URL}"
puts "Fortune 500 satırı: #{fortune_500.length}"
puts "Sayısal Market Value: #{rows.length}"
puts "Kapsam dışı/boş Market Value: #{missing.length}"
puts "Minimum: ##{minimum[:rank]} #{minimum[:name]} #{minimum[:raw]} milyon USD #{minimum[:url]}"
puts "Maksimum: ##{maximum[:rank]} #{maximum[:name]} #{maximum[:raw]} milyon USD #{maximum[:url]}"
puts "Eksik sıralar: #{missing.map { |item| item.fetch("rank") }.join(", ")}"
