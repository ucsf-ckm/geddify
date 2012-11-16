require 'test_helper'

class Gedi_utilities_Test < ActiveSupport::TestCase
  
  
  test "generate gedi file name" do  
    # GEDI standard
    # 10.2
    # A filename will have to conform to the following rules:
    # 8 characters long, followed optionally by a “.” separator and a three character extension;
    # contains only uppercase (A, B, C, ...Z) and digits (0, 1, ...9), except for the separator;
    # consists of a unique system ID, followed by a sequence number.
  
    filename = Gedi_utilities.generate_gedi_file_name(APP_CONFIG['ftp_ipaddress'], '100').split('.')
    assert_equal filename[0].length, 8
    assert_equal filename[1].length, 3
  end
  
  test "get gedi headers from file" do
    gedi_headers = Hash.new
    gedi_headers = Gedi_utilities.parse_gedi_headers('test/fixtures', '12345678.90A')
    assert_equal gedi_headers.size, 11
    assert_equal 'GEDI-1', gedi_headers['IFID']
  end
  
  test "test return nil on attept to parse non or badly formed gedi file" do
    gedi_headers = Hash.new
    gedi_headers = Gedi_utilities.parse_gedi_headers('test/fixtures', 'non-gedi-file.tif')
    
    assert_nil gedi_headers
    
  end
    
  test "add gedi headers to file" do

    gedi_headers = Hash.new
    
    gedi_headers["IFID"] = "GEDI-1"
    gedi_headers["IFVR"] = "0"
    gedi_headers["CILN"] = "2048"
    gedi_headers["DFID"] = "TIFF-5.0"
    gedi_headers["SSAD"] = "?=()"
    gedi_headers["CNSN"] = "N=Ariel/Windows;(E=geoffrey.boushey@ucsf.edu)"
    gedi_headers["RCNM"] = "ildx556195"
    gedi_headers["SPLN"] = GEDI_CONFIG['SPLN']
    gedi_headers["SVDT"] = Time.now.strftime("%Y%m%d%H%M%S")
    gedi_headers["RSNM"] = "N=UCSF Ariel Deliver"
    gedi_headers["NMPG"] = "17"
            
    Gedi_utilities.add_gedi_headers_to_file(gedi_headers, 'test/fixtures', 'gedifile.tif')
    
    gedi_headers = Gedi_utilities.parse_gedi_headers('test/fixtures', 'gedifile.tif')
    
    assert_equal gedi_headers.size, 13
    assert_equal 'GEDI-1', gedi_headers['IFID']
  end
  
  test "remove gedi headers from file" do
    assert_equal true, Gedi_utilities.is_valid_gedi_file('test/fixtures', '12345678.90A')  
    gedi_headers = Hash.new
    gedi_headers = Gedi_utilities.parse_gedi_headers('test/fixtures', '12345678.90A')
    Gedi_utilities.remove_gedi_headers_from_file('test/fixtures', '12345678.90A')
    assert_equal false, Gedi_utilities.is_valid_gedi_file('test/fixtures', '12345678.90A')
    Gedi_utilities.add_gedi_headers_to_file(gedi_headers, 'test/fixtures', '12345678.90A')
  end
  
  test "should create valid gedi record from gedi headers" do
    gedi_headers = Hash.new
    
    gedi_headers["IFID"] = "GEDI-1"
    gedi_headers["IFVR"] = "0"
    gedi_headers["CILN"] = "2048"
    gedi_headers["DFID"] = "TIFF-5.0"
    gedi_headers["SSAD"] = "?=()"
    gedi_headers["CNSN"] = "N=Ariel/Windows;(E=geoffrey.boushey@ucsf.edu)"
    gedi_headers["RCNM"] = "ildx556195"
    gedi_headers["SPLN"] = GEDI_CONFIG['SPLN']
    gedi_headers["SVDT"] = Time.now.strftime("%Y%m%d%H%M%S")
    gedi_headers["RSNM"] = "N=UCSF Ariel Deliver"
    gedi_headers["NMPG"] = "17"
    gedi_headers["ZPAD"] = "??????????"
  
    gedifile = Gedifile.new
    gedifile.populate_from_gedi_headers(gedi_headers)
  
    assert gedifile.save
    assert_equal "GEDI-1", gedifile.IFID
  end
    
end
