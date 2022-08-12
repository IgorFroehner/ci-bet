class StartGameScript
  def self.run
    puts "Start Game Script Running, use Ctrl-C to stop."

    while true
      if Game.any_game_active?
        sleep(10)
        next
      end

      pipeline = PipelineService.get_latest

      status = PipelineService.get_status(pipeline['id'])
      if status != 'running'
        puts 'Game still running, waiting for it to finish.'
        sleep(10)
        next
      end

      team = Team.find_by(team_id: ENV['TEAM_ID'])
      slack_client = Slack::Web::Client.new(token: team.token)

      slack_client.chat_postMessage(
        channel: ENV['CHANNEL_ID'],
        blocks: message(pipeline)
      )

      Game.create(pipeline: pipeline)

      Rails.logger.info("StartGameJob: pipeline #{pipeline}")

      sleep(10)
    end
  end

  def self.message(pipeline)
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
          "text": "*Commit:* #{pipeline['vcs']['commit']['subject']}\n*Branch:* #{pipeline['vcs']['branch']}\n*By:* #{pipeline['trigger']['actor']['login']}\n*Started at:* #{pipeline['trigger']['received_at']}\n"
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
          "text": "Run `/bet <F|S> <amount>`!"
        }
      }
    ]
  end
end

StartGameScript.run if __FILE__ == $0
