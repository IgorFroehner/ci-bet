# frozen_string_literal: true

class CircleCiService
  class << self
    CIRCLE_TOKEN = ENV.fetch('CIRCLE_CI_API_TOKEN')

    def send_request(url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(url)
      request['Circle-Token'] = CIRCLE_TOKEN
      request['Accept'] = 'text/plain'

      response = http.request(request)
      JSON.parse(response.read_body)
    end
  end
end