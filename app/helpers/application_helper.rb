module ApplicationHelper
  def public_demo_text(value)
    public_demo_read_only? ? Privacy::Redactor.call(value) : value
  end

  def public_requester_label(ticket)
    return ticket.requester_reference if ticket.privacy_mode?
    return ticket.requester_name unless public_demo_read_only?

    "Anonim demo müşteri"
  end
end
