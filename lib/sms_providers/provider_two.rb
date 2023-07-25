require 'net/http'
require 'uri'

class SmsProviders::ProviderTwo
  def send_sms(phone_number, message, callback_url)
    url = URI.parse("https://mock-text-provider.parentsquare.com/provider2")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.read_timeout = 10

    request = Net::HTTP::Post.new(url.path)
    request['Content-Type'] = 'application/json'

    message_data = {
      to_number: phone_number,
      message: message,
      callback_url: callback_url
    }.to_json

    request.body = message_data
    response = http.request(request)

    raise StandardError unless response.is_a?(Net::HTTPSuccess)

    response
  end
end
