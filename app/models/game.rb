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

  def end_game(status)
    self.active = false

    unless self.entries.empty?
      total_prize = 0
      self.entries.each do |entry|
        if status
          total_prize += entry["amount"] if entry["bet"] == "F"
        else
          total_prize += entry["amount"] if entry["bet"] == "S"
        end
      end
      total_win_bet = self.total_amount - total_prize

      self.entries.each do |entry|
        user = User.find_by(user_id: entry['user_id'])

        if status
          user.credit_balance(total_prize * entry["amount"] / total_win_bet * 1.0) if entry["bet"] == "S"
        else
          user.credit_balance(total_prize * entry["amount"] / total_win_bet * 1.0) if entry["bet"] == "F"
        end
      end
    end

    self.save
  end

  def self.any_game_active?
    Game.where(active: true).count != 0
  end
end


# 1 S 10
# 2 S 20
# 3 F 10
# 4 F 100

# S win
# total prize 110
# 1: 110 * (10 / 30) =
# 2: 110 * (20 / 30)
