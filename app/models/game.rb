class Game < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :finished, -> { where(active: false) }
end
