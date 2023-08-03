class CreateTeamsUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :teams_users, id: false  do |t|
      t.belongs_to :user, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.belongs_to :team, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.timestamps
    end
  end
end
