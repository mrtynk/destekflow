# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
agents = [
  [ "Ayşe Yılmaz", "ayse@destekflow.example" ],
  [ "Mehmet Kaya", "mehmet@destekflow.example" ]
].map { |name, email| Agent.find_or_create_by!(email:) { |agent| agent.name = name } }

if Ticket.none?
  ticket = Tickets::Create.call({ subject: "Fatura ekranına erişemiyorum", description: "Son faturamı indirmek istediğimde boş sayfa görüyorum.", requester_name: "Deniz Arslan", requester_email: "deniz@example.com", category: "billing", priority: "high" })
  Tickets::Assign.call(ticket:, agent: agents.first)
end
