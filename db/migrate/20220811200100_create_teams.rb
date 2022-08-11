class CreateTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|
      t.string :oauth_version
      t.boolean :active
      t.string :token
      t.string :oauth_scope
      t.string :team_id
      t.string :name
      t.string :activated_user_id
      t.string :activated_user_access_token
      t.string :bot_user_id

      t.timestamps
    end
  end
end
