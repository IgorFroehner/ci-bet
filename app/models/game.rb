class Game
  include Mongoid::Document
  include Mongoid::Timestamps

  field :pipeline, type: Hash, default: {}
  field :active, type: Boolean, default: true
  field :entries, type: Array, default: []
  field :total_amount, type: Integer, default: 0

  def add_entry(user_id, bet, amount)
    self.entries << {
      "user_id": user_id,
      "bet": bet,
      "amount": amount
    }
    self.total_amount += amount

    self.save
  end

  def end_game

  end

  def self.any_game_active?
    Game.where(active: true).count != 0
  end
end
