require 'test_helper'

class Ftp_integration_Test < ActiveSupport::TestCase
  
  test "send file to ftp succeeds" do  
    assert_equal true, Gedi_utilities.ftp_send('127.0.0.1', '419', 'test/fixtures', '12345678.90A', 'document', '7F#####1')
  end
  
  test "send file to ftp fails" do
    assert_equal false, Gedi_utilities.ftp_send('127.0.0.1', '419', 'test/fixtures', '12345678.90A', 'document', 'badpassword')
  end
  
end