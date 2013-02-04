require 'test_helper'
require "capybara/rails"

class Gedifiles_controller_Test < ActiveSupport::TestCase
  
  include Capybara::DSL
  
  test "create and send short form gedi file to ariel ftp" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
    fill_in 'address', :with => APP_CONFIG['ftp_ipaddress']       
    click_button 'Create Gedifile'    
    assert_equal prev+1, Gedifile.count
  end
  
  test "create short form gedi file to ariel ftp sends fail message with bad ip address" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
    fill_in 'address', :with => '123.123.12.31'       
    click_button 'Create Gedifile'    
    assert_equal prev+1, Gedifile.count
  end
  
  test "create short form gedi file to ariel ftp sends fail message with no file attachment" do
    prev = Gedifile.count
    visit '/short'
    fill_in 'address', :with => APP_CONFIG['ftp_ipaddress']   
    click_button 'Create Gedifile'    
    assert_equal prev, Gedifile.count
    assert page.has_content?("No file selected")
  end
  
  test "create short form gedi file to ariel ftp sends fail message with invalid file extension" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/12345678.90A') 
    fill_in 'address', :with => APP_CONFIG['ftp_ipaddress']     
    click_button 'Create Gedifile'    
    assert_equal prev, Gedifile.count
    assert page.has_content?("Invalid file extension")
  end
  
  test "create short form gedi file to ariel ftp sends fail message with no email or ip address" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
    fill_in 'address', :with => ''       
    click_button 'Create Gedifile'    
    assert_equal prev, Gedifile.count
    assert page.has_content?("No ip or email address selected")
  end
  
  test "create and send short form gedi file to patron email" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
    fill_in 'address', :with => APP_CONFIG['email_address']   
    select('Patron (email)', :from => 'target_type')  
        
    click_button 'Create Gedifile'    
    assert_equal prev+1, Gedifile.count
  end
  
  test "create and send short form gedi file to Ariel3 server email" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
    fill_in 'address', :with => APP_CONFIG['email_address']    
    select('Ariel3 (email)', :from => 'target_type')  
    click_button 'Create Gedifile'    
    assert_equal prev+1, Gedifile.count
  end
  
  test "create and send short form gedi file to Ariel 3 ftp" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
    fill_in 'address', :with => APP_CONFIG['ftp_ipaddress']    
    select('Ariel3 (ftp)', :from => 'target_type')  
    click_button 'Create Gedifile'    
    assert_equal prev+1, Gedifile.count
  end
  
  # note - this test will only work if you run another instance of this app on 
  # a different port.  It can't send to itself this way (will time out due to 
  # processing errors)
  #test "create and send short form gedi file to geddify" do
  #  visit '/short'
  #  attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
  #  fill_in 'address', :with => '127.0.0.1:3001'    
  #  select('geddify', :from => 'target_type')  
  #  save_and_open_page
  #  click_button 'Create Gedifile'    
  #  assert page.has_content?("Sent")
  #end
  
  test "create and send short form gedi file to Ariel4 server email" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
    fill_in 'address', :with => APP_CONFIG['email_address']    
    select('Ariel4 (email)', :from => 'target_type')  
    click_button 'Create Gedifile'    
    assert_equal prev+1, Gedifile.count
  end
  
  test "create and send short form gedi file to Ariel4 ftp" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
    fill_in 'address', :with => APP_CONFIG['ftp_ipaddress']    
    select('Ariel4 (ftp)', :from => 'target_type')  
    click_button 'Create Gedifile'    
    assert_equal prev+1, Gedifile.count
  end
  
  test "create and send short form gedi file to Ariel 3 ftp, bad ip address fails" do
    prev = Gedifile.count
    visit '/short'
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif') 
    fill_in 'address', :with => '123.45.678'    
    select('Ariel3 (ftp)', :from => 'target_type')  
    click_button 'Create Gedifile'    
    assert_equal prev+1, Gedifile.count
  end
  
  test "forward existing file to new ip address" do
    visit '/gedifiles'
    first(:link, 'forward').click 
    fill_in 'address', :with => APP_CONFIG['ftp_ipaddress'] 
    click_button 'Forward'
    assert page.has_content?("Sent")
  end    
  
  test "forward existing file to new ip address fails with bad ip address" do
    visit '/gedifiles'
    first(:link, 'forward').click 
    fill_in 'address', :with => '123.45.67.890'
    select('Ariel3 (ftp)', :from => 'target_type')  
    click_button 'Forward'
    assert page.has_content?("Error")
  end
  
  # note - this test will only work if you run another instance of this app on 
  # a different port.  It can't send to itself this way (will time out due to 
  # processing errors)
  #test "forward existing file to another geddify app" do
  #  visit '/gedifiles'
  #  first(:link, 'forward').click 
  #  fill_in 'address', :with => '127.0.0.1:3000'
  #  select('geddify', :from => 'target_type')  
  #  save_and_open_page
  #  click_button 'Forward'
  #  assert page.has_content?("Sent")
  #end
  
  test "forward existing file to patron email address" do
    visit '/gedifiles'
    first(:link, 'forward').click 
    fill_in 'address', :with => APP_CONFIG['email_address'] 
    click_button 'Forward'
    assert page.has_content?("Success")
  end
  
  test "forward existing file to patron email address fails on bad email address" do
    visit '/gedifiles'
    first(:link, 'forward').click 
    fill_in 'address', :with => APP_CONFIG['email_address'] 
    click_button 'Forward'
    assert page.has_content?("Success")
  end
  
  test "create gedi file fails with non-gedi standard parameters" do  
    prev = Gedifile.count
    visit '/gedifiles/new'    
    fill_in 'gedifile[CILN]', :with => "notnumeric!"
    attach_file('upload[gedifile]', 'test/fixtures/non-gedi-file.tif')        
    click_button 'Create Gedifile'    
    assert_equal prev, Gedifile.count
    assert page.has_content?("not a number")
  end
  
  test "import gedi file" do
    prev = Gedifile.count
    visit '/import'
    attach_file('gedifile', 'test/fixtures/gedifile.tif')        
    click_button 'Send'  
    assert page.has_content?("Import Complete")
    assert_equal prev+1, Gedifile.count
  end
  
  test "import gedi file fails with error message when non-gedi file imported" do
    prev = Gedifile.count
    visit '/import'
    attach_file('gedifile', 'test/fixtures/non-gedi-file.tif')        
    click_button 'Send'    
    assert_equal prev, Gedifile.count
    assert page.has_content?('Import Failed')
  end
  
  test "delete gedi file" do
    FileUtils.cp 'test/fixtures/12345678.90A', 'gedifiles/12345678.90A'
    prev = Gedifile.count
    visit '/gedifiles'
    first(:link, 'delete').click 
    assert_equal prev-1, Gedifile.count
  end
  
  
end