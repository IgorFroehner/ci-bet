SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/sign_in' do |command|
    command.logger.info 'Received a sign_id, creating a user.'
    initial_balance = 1000

    if User.where(user_id: command['user_id']).count != 0
      user = User.find_by(user_id: command['user_id'])

      { text: "You're already signed. Your current balance is: #{user.balance}" }
    else
      User.create!(
        user_name: command['user_name'],
        user_id: command['user_id'],
        balance: initial_balance
      )

      { text:  "You're signed in. Your initial balance is: #{initial_balance}" }
    end
  end
end