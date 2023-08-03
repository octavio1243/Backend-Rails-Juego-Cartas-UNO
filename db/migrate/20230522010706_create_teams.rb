class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.belongs_to :game, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.string :name
      t.integer :score, default: 0
      t.timestamps
    end
  end
end
