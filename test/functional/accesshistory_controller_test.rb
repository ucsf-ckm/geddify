require 'test_helper'

class AccesshistoryControllerTest < ActionController::TestCase
  test "edit long form" do
    get :list, :id => "1"
    assert_response :success
  end
end
