class Game
  include Mongoid::Document
  include Mongoid::Timestamps

  field :pipeline, type: Hash, default: {}
  field :active, type: Boolean, default: true
  field :entries, type: Array, default: []
  field :total_amount, type: Integer, default: 0

  def add_entry(user_id, user_name, bet, amount)
    self.entries << {
      "user_id": user_id,
      "user_name": user_name,
      "bet": bet,
      "amount": amount
    }
    self.total_amount += amount

    self.save
  end

  def end_game(status)
    losers = entries.filter { |entry| status ? entry['bet'] == 'F' : entry['bet'] == 'S' }
    losers = losers.map { |entry| [entry, -entry['amount']] }

    winners = entries.filter { |entry| status ? entry['bet'] == 'S' : entry['bet'] == 'F' }
    winner_pool = winners.pluck(:amount).sum

    winners = winners.map do |entry|
      user = User.find_by(user_id: entry['user_id'])
      final_balance = total_amount * (1.0 * entry['amount'] / winner_pool)
      final_balance = final_balance.to_i
      user.credit_balance(final_balance)
      [entry, final_balance]
    end

    self.save
    winners.concat(losers).sort_by { |_, balance | balance }.reverse
  end

  def self.any_game_active?
    Game.where(active: true).count != 0
  end
end
