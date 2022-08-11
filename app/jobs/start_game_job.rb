class StartGameJob < ActiveJob::Base
  def perform
    return if Game.any_game_active?

    pipeline = PipelineService.get_latest_pipeline

    game = Game.create(pipeline: pipeline)

    team = Team.find_by(team_id: ENV['TEAM_ID'])
    slack_client = Slack::Web::Client.new(token: team.token)

    slack_client.chat_postMessage(
      channel: ENV['CHANNEL_ID'],
      text: "Game started. The current pipeline is:
          branch name: #{pipeline['vcs']['branch']}
          runned by: #{pipeline['trigger']['actor']['login']}
          started running: #{pipeline['trigger']['received_at']}
          commit message: #{pipeline['vcs']['commit']['subject']}")

    game.update(active: false)
  end
end
