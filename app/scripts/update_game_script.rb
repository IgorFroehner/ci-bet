class UpdateGameScript
  def self.run
    puts "Update Game Script Running, use Ctrl-C to stop."

    team = Team.find_by(team_id: ENV['TEAM_ID'])
    slack_client = Slack::Web::Client.new(token: team.token)

    while true
      unless Game.any_game_active?
        sleep(1)
        next
      end

      Game.where(active: true).all.each { |game|
        slack_client.chat_update(
          channel: ENV['CHANNEL_ID'],
          ts: game.message['ts'],
          blocks: message(game)
        )

        Rails.logger.info("UpdateGameJob")

        sleep(1)
      }
    end
  end

  def self.message(game)
    pipeline = game.pipeline

    fails = game.entries.filter { |entry| entry['bet'] == 'F' }
    fail_pool = fails.pluck(:amount).sum
    fail_odd = (1.0 * game.total_amount / fail_pool).round(2)
    fail_odd = 1.0 if fail_pool == 0

    successes = game.entries.filter { |entry| entry['bet'] == 'S' }
    success_pool = successes.pluck(:amount).sum
    success_odd = (1.0 * game.total_amount / success_pool).round(2)
    success_odd = 1.0 if success_pool == 0

    commit = pipeline['vcs']
    commit = commit['commit'] if commit
    commit = commit['subject'] if commit

    [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": ":meowparty: New Game Starting :meowparty:",
          "emoji": true
        }
      }, {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*Commit:* #{commit}\n*Branch:* #{pipeline['vcs']['branch']}\n*By:* #{pipeline['trigger']['actor']['login']}\n*Started at:* #{pipeline['trigger']['received_at']}\n"
        },
        "accessory": {
          "type": "image",
          "image_url": "https://cdn.iconscout.com/icon/free/png-256/circleci-283066.png",
          "alt_text": "circle ci image"
        }
      }, {
        "type": "divider"
      }, {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*Bets:* :white_check_mark:   #{success_pool}    :x:   #{fail_pool}
*Odds*: :white_check_mark: #{success_odd}    :x:   #{fail_odd}"
        }
      }, {
        "type": "divider"
      }, {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "Run `/bet <F|S> <amount>`!"
        }
      }
    ]
  end
end

UpdateGameScript.run if __FILE__ == $0
