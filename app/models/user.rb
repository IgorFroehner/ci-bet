class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_name, type: String
  field :user_id, type: String
  field :balance, type: Integer, default: 0

  def debit_balance(amount)
    self.balance -= amount
    self.save
  end

  def credit_balance(amount)
    self.balance += amount
    self.save
  end
end
