class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.belongs_to :user , null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.integer :card
      t.integer :max_groups
      t.boolean :finished, default: false
      t.string :token
      t.timestamps
    end
  end
end
