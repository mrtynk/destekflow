class TicketLink < ApplicationRecord
  belongs_to :first_ticket, class_name: "Ticket", inverse_of: :outgoing_ticket_links
  belongs_to :second_ticket, class_name: "Ticket", inverse_of: :incoming_ticket_links

  validates :linked_by, presence: true
  validates :first_ticket_id, uniqueness: { scope: :second_ticket_id }
  validate :canonical_ticket_order

  def other_ticket(ticket)
    return second_ticket if first_ticket_id == ticket.id
    return first_ticket if second_ticket_id == ticket.id

    raise ArgumentError, "Talep bu ilişkiye ait değil."
  end

  private

  def canonical_ticket_order
    return if first_ticket_id.blank? || second_ticket_id.blank? || first_ticket_id < second_ticket_id

    errors.add(:base, "Talep ilişkisi kanonik sırada ve iki farklı kayıt arasında olmalıdır.")
  end
end
