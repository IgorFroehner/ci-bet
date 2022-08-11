# frozen_string_literal: true

class PipelineService
  def get_all_pipelines
    url = URI("#{CIRCLE_API_URL}/project/#{PROJECT_SLUG}/pipeline")
    send_request(url)
  end

  def get_pipeline_by_number(pipeline_number)
    url = URI("#{CIRCLE_API_URL}/project/#{PROJECT_SLUG}/pipeline/#{pipeline_number}")
    send_request(url)
  end

  def get_latest_pipeline
    url = URI("#{CIRCLE_API_URL}/project/#{PROJECT_SLUG}/pipeline")
    send_request(url)[0]
  end

  private

  CIRCLE_API_URL = 'https://circleci.com/api/v2/'
  PROJECT_SLUG = 'gh/trusted/trusted-api'

  CIRCLE_TOKEN = ENV.fetch('CIRCLE_CI_API_TOKEN')

  def send_request(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request['Circle-Token'] = CIRCLE_TOKEN
    request['Accept'] = 'text/plain'

    response = http.request(request)
    response.read_body
  end
end