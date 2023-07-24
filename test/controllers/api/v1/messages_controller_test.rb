require "test_helper"

class Api::V1::MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_v1_messages_create_url
    assert_response :success
  end
end
