class StartGameScript
  def self.run
    logger = ActiveSupport::Logger.new(STDOUT)
    logger = ActiveSupport::TaggedLogging.new(logger)

    logger.info("Start Game Script Running, use Ctrl-C to stop")

    while true
      if Game.any_game_active?
        logger.info("A game is already active, waiting for it to finish")
        sleep(10)
        next
      end

      pipeline = PipelineService.get_latest
      next if pipeline.blank?

      team = Team.find_by(team_id: ENV['TEAM_ID'])
      slack_client = Slack::Web::Client.new(token: team.token)

      message = slack_client.chat_postMessage(
        channel: ENV['CHANNEL_ID'],
        blocks: message(pipeline)
      )

      Game.create(pipeline: pipeline, message: message)

      logger.info("StartGameJob: pipeline #{pipeline}")

      sleep(10)
    end
  end

  def self.message(pipeline)
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
          "text": "*Bets:* :white_check_mark:   0    :x:   0
*Ods*:  :white_check_mark: 1.0    :x:   1.0"
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
