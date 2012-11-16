require 'test_helper'

class GedifilenameTest < ActiveSupport::TestCase
  test "creates a url safe auth token" do
    gedifilename = Gedifilename.new
    gedifilename.generate_token
    assert_not_nil gedifilename.auth_token
  end
end
