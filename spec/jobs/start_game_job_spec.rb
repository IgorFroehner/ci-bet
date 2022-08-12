require 'rails_helper'

RSpec.describe StartGameJob, type: :job do
  let(:pipeline) { JSON.parse('{}') }

  before do
    allow(PipelineService).to receive(:get_latest).and_return(pipeline)
  end

  it 'starts a game if there is no game active' do
    expect(Game.any_game_active?).to be false
    expect(Game.where(pipeline_id: pipeline['id']).exists?).to be false
    expect(PipelineService.get_status(pipeline['id'])).to eq 'running'
    expect(Game.create(pipeline: pipeline)).to be_a Game
    expect(Game.any_game_active?).to be true
  end
end