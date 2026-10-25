class CreateAiAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_analyses do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :status, null: false
      t.string :provider, null: false
      t.string :embedding_model, null: false
      t.string :generation_model, null: false
      t.jsonb :retrieval_evidence, null: false, default: []
      t.text :answer
      t.string :error_code
      t.timestamps
    end

    add_index :ai_analyses, [ :ticket_id, :created_at ]
  end
end
