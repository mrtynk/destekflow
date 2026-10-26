module ApplicationHelper
  def public_demo_text(value)
    Privacy::Redactor.call(value)
  end

  def public_requester_label(ticket)
    return ticket.requester_reference if ticket.privacy_mode?
    "Anonim müşteri"
  end
end
