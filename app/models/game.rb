class Game
  include Mongoid::Document
  include Mongoid::Timestamps

  field :pipeline, type: Hash, default: {}
  field :active, type: Boolean, default: true
  field :entries, type: Array, default: []

  def self.any_game_active?
    Game.where(active: true).count != 0
  end
end
