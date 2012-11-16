require 'test_helper'

class GedifileTest < ActiveSupport::TestCase
  
  test "gedifile should save if all mandatory attributes are provided" do
    gedifile = Gedifile.new
    gedifile.IFID = 'GEDI-1'
    gedifile.IFVR = "0"
    gedifile.CILN = "2048"
    gedifile.DFID = "TIFF-5.0"
    gedifile.SSAD = "?=()"
    gedifile.CNSN = GEDI_CONFIG['CNSN']
    gedifile.RCNM = "ildx556195"
    gedifile.SPLN = GEDI_CONFIG['SPLN']
    gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
    gedifile.RSNM = "N=UCSF Ariel Deliver"
    gedifile.NMPG = "17"
    
    assert gedifile.save
    
    assert_equal 'GEDI-1', gedifile.IFID
  end
  
  test "gedifile should not save if one or more mandatory attributes are not provided" do
    
    gedifile = Gedifile.new
    
    #missing mandatory attribute
    #gedifile.IFID = 'GEDI-1'
    gedifile.IFVR = "0"
    gedifile.CILN = "2048"
    gedifile.DFID = "TIFF-5.0"
    gedifile.SSAD = "?=()"
    gedifile.CNSN = GEDI_CONFIG['CNSN']
    gedifile.RCNM = "ildx556195"
    gedifile.SPLN = GEDI_CONFIG['SPLN']
    gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
    gedifile.RSNM = "N=UCSF Ariel Deliver"
    gedifile.NMPG = "17"
    
    assert !gedifile.save
      
  end
  
  test "get client ftp address" do
    gedifile = Gedifile.new
    
    gedifile.IFID = 'GEDI-1'
    gedifile.IFVR = "0"
    gedifile.CILN = "2048"
    gedifile.DFID = "TIFF-5.0"
    gedifile.SSAD = "?=()"
    gedifile.CNSN = "N=Ariel/Windows;F=(A=123.45.678.90)"
    gedifile.RCNM = "ildx556195"
    gedifile.SPLN = GEDI_CONFIG['SPLN']
    gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
    gedifile.RSNM = "N=UCSF Ariel Deliver"
    gedifile.NMPG = "17"
    
    assert_equal '123.45.678.90', gedifile.getclientaddress
  end
  
  test "get client email address" do
     gedifile = Gedifile.new

     gedifile.IFID = 'GEDI-1'
     gedifile.IFVR = "0"
     gedifile.CILN = "2048"
     gedifile.DFID = "TIFF-5.0"
     gedifile.SSAD = "?=()"
     gedifile.CNSN = "N=Ariel/Windows;E=geoffrey.boushey@ucsf.edu"
     gedifile.RCNM = "ildx556195"
     gedifile.SPLN = GEDI_CONFIG['SPLN']
     gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
     gedifile.RSNM = "N=UCSF Ariel Deliver"
     gedifile.NMPG = "17"

     assert_equal 'geoffrey.boushey@ucsf.edu', gedifile.get_client_email_address
     
     gedifile.CNSN = "E=geoffrey.boushey@ucsf.edu;N=Ariel/Windows"
     
     assert_equal 'geoffrey.boushey@ucsf.edu', gedifile.get_client_email_address
     
   end
   
   test "convert ip to hash" do
     gedifile = Gedifile.new

     gedifile.IFID = 'GEDI-1'
     gedifile.IFVR = "0"
     gedifile.CILN = "2048"
     gedifile.DFID = "TIFF-5.0"
     gedifile.SSAD = "?=()"
     gedifile.CNSN = "N=Ariel/Windows;F=(A=123.45.678.90)"
     gedifile.RCNM = "ildx556195"
     gedifile.SPLN = "N=Ariel/Windows;F=(A=123.45.678.90)"
     gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
     gedifile.RSNM = "N=UCSF Ariel Deliver"
     gedifile.NMPG = "17"

     assert_equal '7B2D2A65A', gedifile.hash_ip_address
    
   end
   
   test "convert ip to hash, with directory information" do
     gedifile = Gedifile.new

     gedifile.IFID = 'GEDI-1'
     gedifile.IFVR = "0"
     gedifile.CILN = "2048"
     gedifile.DFID = "TIFF-5.0"
     gedifile.SSAD = "?=()"
     gedifile.CNSN = "N=Ariel/Windows;F=(A=123.45.678.90)"
     gedifile.RCNM = "ildx556195"
     gedifile.SPLN = "N=Ariel/Windows;F=(A=123.45.678.90;D=C:\PROGRA\RLG\Ariel\OUT)"
     gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
     gedifile.RSNM = "N=UCSF Ariel Deliver"
     gedifile.NMPG = "17"

     assert_equal '7B2D2A65A', gedifile.hash_ip_address
    
   end
   
   test "get remote server ip address" do
     gedifile = Gedifile.new

     gedifile.IFID = 'GEDI-1'
     gedifile.IFVR = "0"
     gedifile.CILN = "2048"
     gedifile.DFID = "TIFF-5.0"
     gedifile.SSAD = "?=()"
     gedifile.CNSN = "N=Ariel/Windows;F=(A=123.45.678.90)"
     gedifile.RCNM = "ildx556195"
     gedifile.SPLN = "N=Ariel/Windows;F=(A=123.45.678.90)"
     gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
     gedifile.RSNM = "N=UCSF Ariel Deliver"
     gedifile.NMPG = "17"

     assert_equal '123.45.678.90', gedifile.getserveraddress
     
     gedifile.SPLN = "N=Ariel/Windows;F=(A=123.45.678.90;D=C:\PROGRA\RLG\Ariel\OUT)"
     
     assert_equal '123.45.678.90', gedifile.getserveraddress
     
     
    
   end
   
  test "get client extension" do 
    gedifile = Gedifile.new

    gedifile.IFID = 'GEDI-1'
    gedifile.IFVR = "0"
    gedifile.CILN = "2048"
    gedifile.DFID = "TIFF-5.0"
    gedifile.SSAD = "?=()"
    gedifile.CNSN = GEDI_CONFIG['CNSN']
    gedifile.RCNM = "ildx556195"
    gedifile.SPLN = GEDI_CONFIG['SPLN']
    gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
    gedifile.RSNM = "N=UCSF Ariel Deliver"
    gedifile.NMPG = "17"
    
    assert_equal 'tif', gedifile.get_file_extension
    
    gedifile.DFID = "JPEG-5.0"
    assert_equal 'jpeg', gedifile.get_file_extension
    
    gedifile.DFID = "PDF-5.0"
    assert_equal 'pdf', gedifile.get_file_extension
    
    gedifile.DFID = "GIF-5.0"
    assert_equal 'gif', gedifile.get_file_extension
    
    gedifile.DFID = "BMP-5.0"
    assert_equal 'bmp', gedifile.get_file_extension
  end
  
  test "get_gedi_attributes should return a hash of gedifile attribute/value pairs with id, created_at, updated_at, and ZPAD removed" do
  
    # the purpose of the get_gedi_attributes method is to return a hash with all of the gedifile attributes
    # that correspond to a gedi header.  This is useful for creating views.
    # ZPAD is a gedi header, but it is a calculated value (the amount of buffering that needs to be added)
    # so it shouldn't be set by the user and is also removed from this hash
    
    gedifile = Gedifile.new
    gedi_headers = gedifile.attributes
    assert gedi_headers.has_key?('ZPAD')
    assert gedi_headers.has_key?('id')
    assert gedi_headers.has_key?('created_at')
    assert gedi_headers.has_key?('updated_at')
    
    gedi_headers = gedifile.get_gedi_attributes
    assert !gedi_headers.has_key?('ZPAD')
    assert !gedi_headers.has_key?('id')
    assert !gedi_headers.has_key?('created_at')
    assert !gedi_headers.has_key?('updated_at')
  end
  
  test "set_mandatory_headers should set all mandatory headers from config file" do
    gedifile = Gedifile.new
    gedifile.set_mandatory_headers(APP_CONFIG['ftp_ipaddress'])
    
    assert_equal GEDI_CONFIG['IFID'], gedifile.IFID
    assert_equal gedifile.IFVR, GEDI_CONFIG['IFVR']
    assert_equal gedifile.CILN, GEDI_CONFIG['CILN']
    assert_equal gedifile.DFID, GEDI_CONFIG['DFID']   
    assert_equal gedifile.SSAD, GEDI_CONFIG['SSAD']
    assert_equal gedifile.CNSN, GEDI_CONFIG['CNSN']
    assert_equal gedifile.RCNM, GEDI_CONFIG['RCNM']
    assert_equal gedifile.SPLN, GEDI_CONFIG['SPLN']
    assert_equal gedifile.RSNM, GEDI_CONFIG['RSNM']
    assert_equal gedifile.RSNT, GEDI_CONFIG['RSNT']
    assert_equal gedifile.NMPG, GEDI_CONFIG['NMPG']
  end
  
  test "set_ariel3 should set only ariel3 headers (missing a mandatory field)" do
    gedifile = Gedifile.new
    gedifile.set_ariel3_headers(APP_CONFIG['ftp_ipaddress'])
    assert_equal GEDI_CONFIG['IFID'], gedifile.IFID
    assert_equal GEDI_CONFIG['IFVR'], gedifile.IFVR
    assert_equal GEDI_CONFIG['CILN'], gedifile.CILN
    assert_equal GEDI_CONFIG['DFID'], gedifile.DFID
    assert_equal GEDI_CONFIG['CNSN'], gedifile.CNSN
    assert_equal GEDI_CONFIG['RCNM'], gedifile.RCNM
    assert_equal GEDI_CONFIG['SPLN'], gedifile.SPLN
    assert_equal GEDI_CONFIG['RSNM'], gedifile.RSNM
    assert_equal GEDI_CONFIG['CPRT'], gedifile.CPRT
    assert_equal GEDI_CONFIG['NMPG'], gedifile.NMPG
  end
  
  test "set_ariel4 should set only ariel4 headers" do
    gedifile = Gedifile.new
    gedifile.set_ariel4_headers(APP_CONFIG['ftp_ipaddress'])
    assert_equal GEDI_CONFIG['IFID'], gedifile.IFID
    assert_equal GEDI_CONFIG['IFVR'], gedifile.IFVR
    assert_equal GEDI_CONFIG['CILN'], gedifile.CILN
    assert_equal GEDI_CONFIG['DFID'], gedifile.DFID
    assert_equal GEDI_CONFIG['SSAD'], gedifile.SSAD
    assert_equal GEDI_CONFIG['CNSN'], gedifile.CNSN
    assert_equal GEDI_CONFIG['RCNM'], gedifile.RCNM
    assert_equal GEDI_CONFIG['SPLN'], gedifile.SPLN
    assert_equal GEDI_CONFIG['CLNT'], gedifile.CLNT
    assert_equal GEDI_CONFIG['RSNM'], gedifile.RSNM
    assert_equal GEDI_CONFIG['RSNT'], gedifile.RSNT
    assert_equal GEDI_CONFIG['NMPG'], gedifile.NMPG
  end
  
  #test "gedi file names must be eight digit hex number followed by a dot followed by a three digit hex number" do
  #end
      
end
