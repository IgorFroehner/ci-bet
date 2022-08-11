class EndGameJob < ActiveJob::Base
  def perform
    return unless Game.any_game_active?

    game = Game.where(active: true).first

    pipeline = game.pipeline
    status = PipelineService.get_status(pipeline['id'])

    return if status == 'running'

    game.end_game(status == 'success')

    team = Team.find_by(team_id: ENV['TEAM_ID'])
    slack_client = Slack::Web::Client.new(token: team.token)

    slack_client.chat_postMessage(
      channel: ENV['CHANNEL_ID'],
      text: "Pipeline \"#{pipeline['vcs']['commit']['subject']}\" has finished running with status #{status}
Distributing gains!!!"
    )

    Rails.logger.info("EndGameJob: pipeline #{pipeline}")
  end
end
