class CloseResolvedTicketsJob < ApplicationJob
  queue_as :default

  def perform(at: Time.current)
    Ticket.where(status: "solved", resolved_at: ..(at - 48.hours)).find_each do |ticket|
      Tickets::Transition.call(ticket:, to: "closed", actor_name: "Sistem", at:)
    end
  end
end
