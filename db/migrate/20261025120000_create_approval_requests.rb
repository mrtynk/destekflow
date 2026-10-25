class CreateApprovalRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :approval_requests do |t|
      t.references :ticket, null: false, foreign_key: true
      t.text :reason, null: false
      t.string :requested_action, null: false
      t.string :decision_owner, null: false
      t.string :requested_by, null: false
      t.string :status, null: false, default: "requested"
      t.datetime :escalated_at
      t.datetime :decided_at
      t.string :decided_by
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end

    add_index :approval_requests, %i[status created_at]
    add_check_constraint :approval_requests,
                         "status IN ('requested', 'approved', 'rejected', 'escalated')",
                         name: "approval_requests_valid_status"

    create_table :approval_events do |t|
      t.references :approval_request, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :actor_name, null: false
      t.text :details, null: false
      t.timestamps
    end
  end
end
