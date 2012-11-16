require 'test_helper'

class GedifilesControllerTest < ActionController::TestCase

  setup do
    @request.env['HTTP_REFERER'] = '/gedifiles'
    post :create, { :user => { :email => 'invalid@abc' } }
  end

  # tests for controller methods create, destroy, and import_gedi_file are in integration test section
  
  test "index should render all gedi files" do
    get :index
    assert_response :success
  end
  
  test "index should render all pending status" do
    get :index, :status => "pending"
    assert_response :success
  end
  
  test "file sync" do
    get :ftp_sync
    assert_response :redirect
  end
  
  test "new" do
    get :new
    assert_response :success
  end
  
  test "short form" do
    get :short
    assert_response :success
  end

  test "long form" do
    get :longform
    assert_response :success
  end
  
  test "ariel3" do
    get :ariel3
    assert_response :success
  end
  
  test "ariel4" do
    get :ariel4
    assert_response :success
  end
  
  test "edit" do
    get :edit, :id => "1"
    assert_response :success
  end
  
  test "edit long form" do
    get :editlongform, :id => "1"
    assert_response :success
  end
  
  test "update" do 
    post :update, :id=>"1", :prev_url => '/gedifiles', :lock_version => Gedifile.find(1).lock_version.to_s, :gedifile => {:IFID => 'newIFID'}
    assert_response :redirect
    assert_equal "newIFID", Gedifile.find(1).IFID
  end
  
  test "update fails when trying to update stale object" do
    post :update, :id=>"1", :prev_url => '/gedifiles', :lock_version =>"999", :gedifile => {:IFID => 'failedIFID'}
    assert_response :redirect
    assert_not_equal "failedIDID", Gedifile.find(1).IFID
  end

  test "no update for invalid parameters" do 
    post :update, :id=>"1", :lock_version => "0", :gedifile => {:CILN => 'notnumeric'}
    assert_response :success
    assert_equal 'GEDI-1', Gedifile.find(1).IFID
  end
  
  test "file download page" do
    FileUtils.cp 'test/fixtures/12345678.90A', 'gedifiles/12345678.90A'
    get :file_download_page, :auth_token => "1234"
    assert_response :success
  end
  
  test "file download page fails when no auth token found" do
    get :file_download_page, :auth_token => "9999"
    assert_response :redirect
  end
  
  test "file download" do
    FileUtils.cp 'test/fixtures/12345678.90A', 'gedifiles/12345678.90A'
    get :file_download, :auth_token => "1234"
  end
  
  test "file download fails when no auth token found" do
    get :file_download, :auth_token => "9999"
    assert_response :redirect
  end
  
  test "gedi download" do
    FileUtils.cp 'test/fixtures/12345678.90A', 'gedifiles/12345678.90A'
    get :gedi_download, :auth_token => "1234"
  end
  
  test "gedi download fails when no auth token found" do
    get :gedi_download, :auth_token => "9999"
    assert_response :redirect
  end
  
  test "forward file" do
    get :forward, :id => "2"
    assert_response :success
  end
  
  test "send forward file via ftp" do
    post :send_forward, :lock_version => Gedifile.find(2).lock_version.to_s, :id => "2", :address=>'127.0.0.1'
    assert_response :redirect
  end
  
  test "send forward file via email" do
    post :send_forward, :id => "2", :lock_version => Gedifile.find(2).lock_version.to_s, :address=>'geoffrey.boushey@ucsf.edu'
    assert_response :redirect
  end
  
  test "send forward file via email without address" do
    post :send_forward, :id => "2", :lock_version => Gedifile.find(2).lock_version.to_s
    assert_response :redirect
  end
  
end

