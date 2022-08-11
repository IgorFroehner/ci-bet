class CreateBettingGames < ActiveRecord::Migration[6.0]
  def change
    create_table :betting_games do |t|

      t.timestamps
    end
  end
end
