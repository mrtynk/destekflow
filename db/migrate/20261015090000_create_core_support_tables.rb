class CreateCoreSupportTables < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.timestamps
    end
    add_index :agents, :email, unique: true

    create_table :tickets do |t|
      t.string :subject, null: false
      t.text :description, null: false
      t.string :requester_name, null: false
      t.string :requester_email, null: false
      t.string :category, null: false
      t.string :priority, null: false, default: "normal"
      t.string :status, null: false, default: "new"
      t.references :assignee, foreign_key: { to_table: :agents }
      t.datetime :sla_due_at, null: false
      t.datetime :first_responded_at
      t.datetime :resolved_at
      t.datetime :closed_at
      t.timestamps
    end
    add_index :tickets, %i[status sla_due_at]

    create_table :replies do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end

    create_table :ticket_events do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :actor_name, null: false
      t.text :details, null: false
      t.timestamps
    end
  end
end
