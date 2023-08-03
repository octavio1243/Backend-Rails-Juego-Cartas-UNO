class CreateGamesUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :games_users do |t|
      t.references :user, null: false, foreign_key: true, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.references :game, null: false, foreign_key: true, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.integer :score, default: 0
      t.timestamps
    end
  end
end
