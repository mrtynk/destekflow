class CreateAiUsageBudgets < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_usage_budgets do |t|
      t.string :provider, null: false
      t.datetime :minute_started_at, null: false
      t.integer :minute_count, null: false, default: 0
      t.date :day_started_on, null: false
      t.integer :day_count, null: false, default: 0
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end

    add_index :ai_usage_budgets, :provider, unique: true
  end
end
