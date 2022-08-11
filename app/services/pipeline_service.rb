# frozen_string_literal: true

class PipelineService
  class << self
    CIRCLE_API_URL = 'https://circleci.com/api/v2'
    PROJECT_SLUG = 'gh/trusted/trusted-api'

    def get_all
      url = URI("#{CIRCLE_API_URL}/project/#{PROJECT_SLUG}/pipeline")
      CircleCiService.send_request(url)
    end

    def get_latest
      get_all['items'].first
    end

    def get_by_id(pipeline_id)
      url = URI("#{CIRCLE_API_URL}/pipeline/#{pipeline_id}")
      CircleCiService.send_request(url)
    end

    def get_workflow(pipeline_id)
      url = URI("#{CIRCLE_API_URL}/pipeline/#{pipeline_id}/workflow")
      CircleCiService.send_request(url)
    end

    def get_status(pipeline_id)
      get_workflow(pipeline_id)['items'][0]['status']
    end
  end
end