class Api::V1::MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    phone_number = params[:phone_number]
    body = params[:body]

    if /^(3|4)/.match?(phone_number)
      render status: :bad_request, json: { error: "Invalid Phone number: #{phone_number}, phone numbers cannot start with a 3 or 4"}
    elsif phone_number.empty? || body.empty?
      render status: :bad_request, json: { error: "Missing required params"}
    else
      callback_url = ENV["CALLBACK_URL"]

      providers_to_try = [SmsProviders::ProviderOne, SmsProviders::ProviderTwo]
  
      # Initialize a variable to store the response from the successful provider
      successful_response = nil
      # Try sending the message using each provider until one is successful
      providers_to_try.each do |provider_class|
        begin
          # Things to add: timeout rescue 
          provider_instance = provider_class.new
          successful_response = provider_instance.send_sms(phone_number, body, callback_url)
          
          # If the message was sent successfully, break out of the loop
          break if successful_response.code == 200
        rescue StandardError => e
          Rails.logger.error("Failed to send message using #{provider_class.name}: #{e.message}")
        end
      end

      response_body = JSON.parse(successful_response.body)
      
      message = Message.create(
        phone_number: phone_number,
        body: body,
        status: "sending",
        message_id: response_body["message_id"]
      )
  
      render json: { message: message }
    end
  end

  def callback
    message = Message.find_by(message_id: params[:message_id])

    if message
      message.update(status: params[:status])
      render json: { message: message}
    else
      render json: { status: :not_found, error: "Message: #{params[:message_id]} not found"}
    end
  end
  
end
