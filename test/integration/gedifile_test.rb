require 'test_helper'
require "capybara/rails"

class Ftp_integration_Test < ActiveSupport::TestCase
  
  include Capybara::DSL
  
  test "ingest ftp files" do
    # note - for full unit test coverage, there must be files present in the ftp server that are not currently
    # ingested into the app.  So we will delete one of the files from this app prior to running this test.
            
    #visit '/gedifiles'

    #while page.has_content?('delete')
    #  click_link 'delete'
    #end
    
    assert_equal true, Gedifile.ingest_ftp_files('127.0.0.1', '419', 'admin', '21232F297A57A5A743894A0E4A801FC3')
  end
  
  test "ingest ftp files fails" do
    assert_equal false, Gedifile.ingest_ftp_files('127.0.0.1', '419', 'admin', 'nothterightpassword')
  end
  
end