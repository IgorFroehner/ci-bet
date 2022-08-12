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
      { text: "👎 Invalid arguments. Usage: /bet <bet> <amount>" }
    else
      bet, amount = text_splited

      if bet == "S" || bet == "F"
        amount = amount.to_i

        if amount < minimum_bet
          { text: "👎 Invalid amount. Minimum bet is: #{minimum_bet}" }
        else
          command.logger.info "Received a bet of #{amount} for #{bet}."

          if User.where(user_id: command['user_id']).count != 0
            user = User.find_by(user_id: command['user_id'])

            if user.balance < amount
              { text: "👎 You don't have enough balance to bet #{amount}."\
                      "       💵 Your current balance is: #{user.balance}" }
            else
              if Game.any_game_active?
                game = Game.where(active: true).first

                game.add_entry(user.user_id, user.user_name, bet, amount)

                user.debit_balance(amount)

                { text: " 💸 You bet #{amount} for #{bet}. 💸 \n"\
                        "    🪁 The pipeline was: #{game.pipeline['vcs']['branch']}\n"\
                        "    💵 Your current balance is: #{user.balance}" }
              else
                { text: "👎 There is no active game, soon you will have the next." }
              end
            end
          else
            { text: "👎 You're not signed in. Please sign in with /sign_in." }
          end
        end
      else
        command.logger.info "Received a bet with invalid argument."

        { text: "Invalid arguments. Give a S,s or F,f meaning what's your bet in the fist param. Usage: /bet <S,s | F,f> <amount>" }
      end
    end
  end
end