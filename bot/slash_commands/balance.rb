
SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/balance' do |command|
    # Command shape:
    #   /balance

    command.logger.info 'Received a balance, giving its answer.'

    if User.where(user_id: command['user_id']).count != 0
      user = User.find_by(user_id: command['user_id'])

      { text: "💵 Your current balance is: #{user.balance} 💵" }
    else
      { text:  "👎 You're not signed in. Please sign in with /sign_in." }
    end
  end
end