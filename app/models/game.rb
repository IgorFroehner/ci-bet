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
    return unless self.active

    self.active = false

    unless self.entries.empty?
      total_prize_success = 0
      total_prize_failure = 0
      self.entries.each do |entry|
        total_prize_success += entry["amount"] if entry["bet"] == "S"
        total_prize_failure += entry["amount"] if entry["bet"] == "F"
      end

      self.entries.each do |entry|
        user = User.find_by(user_id: entry['user_id'])

        if status
          final_balance = self.total_amount * (entry['amount'] / total_prize_success)

          user.credit_balance(final_balance) if entry["bet"] == "S"
        else
          final_balance = self.total_amount * (entry['amount'] / total_prize_failure)

          user.credit_balance(final_balance) if entry["bet"] == "F"
        end
      end
    end

    self.save
  end

  def self.any_game_active?
    Game.where(active: true).count != 0
  end
end
