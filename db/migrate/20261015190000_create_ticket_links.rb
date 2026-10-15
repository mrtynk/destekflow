class CreateTicketLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_links do |t|
      t.references :first_ticket, null: false, foreign_key: { to_table: :tickets }
      t.references :second_ticket, null: false, foreign_key: { to_table: :tickets }
      t.string :linked_by, null: false

      t.timestamps
    end

    add_index :ticket_links, %i[first_ticket_id second_ticket_id], unique: true
    add_check_constraint :ticket_links, "first_ticket_id < second_ticket_id", name: "ticket_links_canonical_order"
  end
end
