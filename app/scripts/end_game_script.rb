
class EndGameScript
  def self.run
    puts 'EndGameScript running, use Ctrl-C to stop.'

    while true
      unless Game.any_game_active?
        sleep(10)
        next
      end

      game = Game.where(active: true).first

      pipeline = game.pipeline
      status = PipelineService.get_status(pipeline['id'])

      if status == 'failing'
        status = 'failed'
      end

      unless finished_status.include?(status)
        puts 'Game still running, waiting for it to finish.'
        sleep(10)
        next
      end

      puts "Game finished, status: #{status}"

      team = Team.find_by(team_id: ENV['TEAM_ID'])
      slack_client = Slack::Web::Client.new(token: team.token)

      message_result = slack_client.chat_postMessage(
        channel: ENV['CHANNEL_ID'],
        blocks: message(pipeline, status)
      )

      if status == 'success' || status == 'failed'
        winners = game.end_game(status == 'success')
        text = winners.map { |entry, balance| "#{entry['user_name']} +#{balance}#{balance >= 10000 ? " #{money_emoji}" : ''}" }.join('\n')

        unless text.blank?
          slack_client.chat_postMessage(
            channel: ENV['CHANNEL_ID'],
            thread_ts: message_result['ts'],
            text: text
          )
        end
      end

      game.update(active: false)

      Rails.logger.info("EndGameJob: pipeline #{pipeline}")
    end
  end

  def self.message(pipeline, status)
    [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "#{emoji(status)} Game Finished #{emoji(status)}",
          "emoji": true
        }
      }, {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "*Commit:* #{pipeline['vcs']['commit']['subject']}\n*By:* #{pipeline['trigger']['actor']['login']}\n*Status:* #{status} :money-money:\n"
        },
        "accessory": {
          "type": "image",
          "image_url": image(status),
          "alt_text": "circle ci image"
        }
      }, {
        "type": "divider"
      }, {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": "Distributing gains!!! :burning-money: Next game will start soon... :flying_money_with_wings:"
        }
      }
    ]
  end

  def self.money_emoji
    %w[:burning-money: :flying_money_with_wings: :rocket_intensifies: :catjam:].sample
  end

  def self.emoji(status)
    if status == 'success'
      ':happy-link:'
    elsif status == 'failed'
      ':rocket_intensifies:'
    else
      ':catjam:'
    end
  end

  def self.finished_status
    %w[success failed canceled]
  end

  def self.image(status)
    if status == 'success'
      'https://i.ibb.co/fxMdzkH/circle-ci-trademark-sucess-c.png'
    elsif status == 'failed'
      'https://i.ibb.co/m6JQXjY/circle-ci-trademark-failed-c.png'
    else
      'https://cdn.iconscout.com/icon/free/png-256/circleci-283066.png'
    end
  end
end

EndGameScript.run if __FILE__ == $0
