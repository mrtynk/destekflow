class CreateAgentRunsAndPrivacyFields < ActiveRecord::Migration[8.1]
  def change
    change_table :tickets, bulk: true do |t|
      t.string :origin, null: false, default: "web"
      t.string :agent_external_reference
      t.string :requester_reference
      t.boolean :privacy_mode, null: false, default: false
    end
    add_index :tickets, :agent_external_reference, unique: true, where: "agent_external_reference IS NOT NULL"

    create_table :agent_runs do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :status, null: false
      t.string :provider, null: false
      t.string :model, null: false
      t.string :decision, null: false
      t.text :reason, null: false
      t.boolean :reply_published, null: false, default: false
      t.text :suggested_reply
      t.jsonb :knowledge_evidence, null: false, default: []
      t.string :error_code
      t.timestamps
    end
    add_index :agent_runs, [ :ticket_id, :created_at ]
  end
end
