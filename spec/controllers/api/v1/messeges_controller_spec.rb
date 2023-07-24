require 'rails_helper'


RSpec.describe Api::V1::MessagesController, type: :controller do
  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { phone_number: '1234567890', body: 'Hello, world!' } }

      before do
        WebMock.stub_request(:post, "https://mock-text-provider.parentsquare.com/provider1").to_return(status: 200, body: "{\"to_number\":\"9547653214\",\"message\":\"Hello, world!\",\"callback_url\":\"https://test.ngrok-free.app/api/v1/messages/callback\"}")
        WebMock.stub_request(:post, "https://mock-text-provider.parentsquare.com/provider2").to_return(status: 200, body: "{\"to_number\":\"2813308004\",\"message\":\"Hello, there!\",\"callback_url\":\"https://test.ngrok-free.app/api/v1/messages/callback\"}")
      end

      it 'creates a new message' do
        expect {
          post :create, params: valid_params
        }.to change(Message, :count).by(1)

        expect(response).to have_http_status(:success)
      end

      it 'returns the message ID in the response' do
        post :create, params: valid_params

        expect(response).to have_http_status(:success)
        expect(response.parsed_body['message']).to be_present
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { phone_number: '', body: '' } }

      it 'does not create a new message' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Message, :count)

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message in the response' do
        post :create, params: invalid_params

        expect(response).to have_http_status(:bad_request)
        expect(response_body['error']).to be_present
      end
    end

  end

  def response_body
    JSON.parse(response.body)
  end
end
