SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/bet' do |command|
    # Command shape:
    #   /bet <S,s | F,f> <amount>
    #   S,s stands for success, F,f for failure
    #   the minimum bet is 1
    #   Example: /bet S 100

    text_splited = command['text'].split()
    minimum_bet = 1

    if text_splited.length != 2
      { text: "Invalid arguments. Usage: /bet <bet> <amount>" }
    else
      bet, amount = text_splited

      if /^[SsFf]$/.match(bet)
        amount = amount.to_i

        if amount < minimum_bet
          { text: "Invalid amount. Minimum bet is: #{minimum_bet}" }
        else
          command.logger.info "Received a bet of #{amount} for #{bet}."

          if User.where(user_id: command['user_id']).count != 0
            user = User.find_by(user_id: command['user_id'])

            if user.balance < amount
              { text: "You don't have enough balance to bet #{amount}. Your current balance is: #{user.balance}" }
            else

              # TODO: here is the betting part

              { text: "You bet #{amount} for #{bet}. Your current balance is: #{user.balance}" }
            end
          else
            { text: "You're not signed in. Please sign in with /sign_in." }
          end
        end
      else
        command.logger.info "Received a bet with invalid argument."

        { text: "Invalid arguments. Give a S,s or F,f meaning what's your bet in the fist param. Usage: /bet <S,s | F,f> <amount>" }
      end
    end
  end
end