# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_25_170000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_agents_on_email", unique: true
  end

  create_table "ai_analyses", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.string "status", null: false
    t.string "provider", null: false
    t.string "embedding_model", null: false
    t.string "generation_model", null: false
    t.jsonb "retrieval_evidence", default: [], null: false
    t.text "answer"
    t.string "error_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id", "created_at"], name: "index_ai_analyses_on_ticket_id_and_created_at"
    t.index ["ticket_id"], name: "index_ai_analyses_on_ticket_id"
  end

  create_table "approval_events", force: :cascade do |t|
    t.bigint "approval_request_id", null: false
    t.string "event_type", null: false
    t.string "actor_name", null: false
    t.text "details", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_request_id"], name: "index_approval_events_on_approval_request_id"
  end

  create_table "approval_requests", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.text "reason", null: false
    t.string "requested_action", null: false
    t.string "decision_owner", null: false
    t.string "requested_by", null: false
    t.string "status", default: "requested", null: false
    t.datetime "escalated_at"
    t.datetime "decided_at"
    t.string "decided_by"
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status", "created_at"], name: "index_approval_requests_on_status_and_created_at"
    t.index ["ticket_id"], name: "index_approval_requests_on_ticket_id"
    t.check_constraint "status::text = ANY (ARRAY['requested'::character varying, 'approved'::character varying, 'rejected'::character varying, 'escalated'::character varying]::text[])", name: "approval_requests_valid_status"
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.bigint "agent_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_replies_on_agent_id"
    t.index ["ticket_id"], name: "index_replies_on_ticket_id"
  end

  create_table "ticket_events", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.string "event_type", null: false
    t.string "actor_name", null: false
    t.text "details", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_ticket_events_on_ticket_id"
  end

  create_table "ticket_links", force: :cascade do |t|
    t.bigint "first_ticket_id", null: false
    t.bigint "second_ticket_id", null: false
    t.string "linked_by", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["first_ticket_id", "second_ticket_id"], name: "index_ticket_links_on_first_ticket_id_and_second_ticket_id", unique: true
    t.index ["first_ticket_id"], name: "index_ticket_links_on_first_ticket_id"
    t.index ["second_ticket_id"], name: "index_ticket_links_on_second_ticket_id"
    t.check_constraint "first_ticket_id < second_ticket_id", name: "ticket_links_canonical_order"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "subject", null: false
    t.text "description", null: false
    t.string "requester_name", null: false
    t.string "requester_email", null: false
    t.string "category", null: false
    t.string "priority", default: "normal", null: false
    t.string "status", default: "new", null: false
    t.bigint "assignee_id"
    t.datetime "sla_due_at", null: false
    t.datetime "first_responded_at"
    t.datetime "resolved_at"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["status", "sla_due_at"], name: "index_tickets_on_status_and_sla_due_at"
  end

  add_foreign_key "ai_analyses", "tickets"
  add_foreign_key "approval_events", "approval_requests"
  add_foreign_key "approval_requests", "tickets"
  add_foreign_key "replies", "agents"
  add_foreign_key "replies", "tickets"
  add_foreign_key "ticket_events", "tickets"
  add_foreign_key "ticket_links", "tickets", column: "first_ticket_id"
  add_foreign_key "ticket_links", "tickets", column: "second_ticket_id"
  add_foreign_key "tickets", "agents", column: "assignee_id"
end
