class CreateMyCards < ActiveRecord::Migration[7.0]
  def change
    create_table :my_cards do |t|
      t.integer :card
      t.belongs_to :user, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.belongs_to :game, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.timestamps
    end
  end
end
