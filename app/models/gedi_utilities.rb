#require 'active_support/secure_random'
require 'net/ftp'

class Gedi_utilities 
  
  # generate a GEDI compliant
  # GEDI standard
  # 10.2
  # A filename will have to conform to the following rules:
  # 8 characters long, followed optionally by a “.” separator and a three character extension;
  # the name is the host IP address converted to hex (2 digit minimum each), and the extension is
  # a 3-digit minimum hex of the record id.  This is required to be compliant with Ariel.
  # note that the id is taken modulo 4096, corresponding to the largest 3-digit hex number
  def self.generate_gedi_file_name(address, id)
    ("%02X%02X%02X%02X" % address.split('.')) + '.' + ("%03X" % id.to_i.modulo(4096)).upcase    
  end
  
  # determine if a file has valid and complete gedi headers
  # TODO
  # currently all we're doing here is verifying that CILN is present
  # and it's just used for unit testing.  Not sure we need this method.
  def self.is_valid_gedi_file(directory, filename)
    file = File.new(directory + "/" + filename, "r")
    header = file.gets
    
    if !header.include?('CILN')
      false
    else
      true
    end
  end
  
  # returns a hash of the GEDI header/value pairs in a GEDI file
  # returns nil if the file is not valid GEDI
  def self.parse_gedi_headers(directory, filename)
    
    begin
    
      file = File.new(directory + "/" + filename, "r")
      header = file.gets
    
      # get the byte length of the header
      ciln_index = header.index('CILN')
      ciln_len = header[ciln_index+4.. ciln_index+7].to_i
      ciln_val = header[ciln_index+8.. ciln_index+7+ciln_len].to_i
    
      hdata = header [0,ciln_val]          
        
      # GEDI headers, ISO 17933
      # mandatory
      
      # using ^~ as a delimiter. 
      hdata = hdata.sub('IFID', "^~IFID") # unique identifier for the interchange format
      hdata = hdata.sub('IFVR', "^~IFVR") # version number for interchange format
      hdata = hdata.sub('CILN', "^~CILN") # byte count of the cover information
      hdata = hdata.sub('DFID', "^~DFID") # document format id
      hdata = hdata.sub('SSAD', "^~SSAD") # delimiters (see gedi standard for more info)
      hdata = hdata.sub('CNSN', "^~CNSN") # destination of document
      hdata = hdata.sub('RCNM', "^~RCNM") # name of the gedi record
      hdata = hdata.sub('SPLN', "^~SPLN") # supplier name (N=name, E=email, F=ftp address, X=fax... FTP is substructured into A=address and D=directory)
      hdata = hdata.sub('SVDT', "^~SVDT") # service-date-time YYYYMMDDHHMMSS

      hdata = hdata.sub('SYID', "^~SYID")
      hdata = hdata.sub('SYAD', "^~SYAD")
      hdata = hdata.sub('DLVS', "^~DLVS")
      hdata = hdata.sub('CNFA', "^~CNFA")
      hdata = hdata.sub('PRTY', "^~PRTY")
      hdata = hdata.sub('GNLN', "^~GNLN")
      hdata = hdata.sub('CLNT', "^~CLNT") # name of reader for whom document is intended (optional)
      hdata = hdata.sub('CLID', "^~CLID")
      hdata = hdata.sub('CLST', "^~CLST")
      hdata = hdata.sub('NPOI', "^~NPOI")
      hdata = hdata.sub('XPDA', "^~XPDA")
      hdata = hdata.sub('STNM', "^~STNM")
      hdata = hdata.sub('POBX', "^~POBX")
      hdata = hdata.sub('CITY', "^~CITY")
      hdata = hdata.sub('REGN', "^~REGN")
      hdata = hdata.sub('CNTR', "^~CNTR")
      hdata = hdata.sub('POCD', "^~POCD")
      hdata = hdata.sub('RQID', "^~RQID")
      hdata = hdata.sub('RQNM', "^~RQNM")
      hdata = hdata.sub('RSID', "^~RSID")
      hdata = hdata.sub('RSNM', "^~RSNM") # responder-name (optional)
      hdata = hdata.sub('CPRT', "^~CPRT")
      hdata = hdata.sub('ILTI', "^~ILTI")
      hdata = hdata.sub('RSNT', "^~RSNT") # free text message (optional)
      hdata = hdata.sub('RCON', "^~RCON")
      hdata = hdata.sub('ATHR', "^~ATHR")
      hdata = hdata.sub('TTLE', "^~TTLE")
      hdata = hdata.sub('VLIS', "^~VLIS")
      hdata = hdata.sub('AART', "^~AART")
      hdata = hdata.sub('TART', "^~TART")
      hdata = hdata.sub('ISBN', "^~ISBN")
      hdata = hdata.sub('ISSN', "^~ISSN")
      hdata = hdata.sub('BBLD', "^~BBLD")
      hdata = hdata.sub('PGNS', "^~PGNS")
      hdata = hdata.sub('DTSC', "^~DTSC")
      hdata = hdata.sub('NMPG', "^~NMPG") # total number of pages (optional)
      hdata = hdata.sub('CLNO', "^~CLNO")
      hdata = hdata.sub('PDOC', "^~PDOC")
      hdata = hdata.sub('PUBD', "^~PUBD")
      hdata = hdata.sub('PLPB', "^~PLPB")
      hdata = hdata.sub('PUBL', "^~PUBL")
      hdata = hdata.sub('EDIT', "^~EDIT")
      hdata = hdata.sub('RQAQ', "^~RQAQ")
      hdata = hdata.sub('STAT', "^~STAT")
      hdata = hdata.sub('ITID', "^~ITID")
      
      # optional
      hdata = hdata.sub('ZPAD', "^~ZPAD") # padding to make it out to the end of the header (specified in CILN) (optional)
    
      hdatas = hdata.split("^~")

      gedi_headers = Hash.new

      hdatas.each do |h|
        gedi_headers[h[0..3]] = h[8..-1]
      end

      gedi_headers

    rescue
      nil
    end

  end

  # takes a hash of gedi header/value pairs and prepends them to a file
  def self.add_gedi_headers_to_file(gedi_headers, directory, filename)
    headerlength = 0
    tempname = generate_gedi_file_name(APP_CONFIG['ftp_ipaddress'], '100')
    tmppath = File.join(directory, tempname)

    File.open(tmppath, "w") do |new|
        gedi_headers.each do|header, value|
                    
        unless value.nil? || header == "ZPAD"
          headerlength += (8 + value.length)        
          new.write "#{header}#{"%04d" % value.length}#{value}"
        end
      end
    
      zpad_length = gedi_headers["CILN"].to_i - headerlength
      new.write "ZPAD" + (zpad_length-8).to_s
      new.write '?'*(zpad_length-8) 
      
    end

    file = File.new(File.join(directory, filename), "r")

    File.open(tmppath, "a") do |new|
      while a = file.gets
        new.puts(a)
      end
    end 
    
    # delete the original file now
    File.delete(directory + "/" + filename)
    
    # rename the temp file to the original file
    File.rename(directory + "/" + tempname, directory + "/" + filename)

    filename
  end
  
  def self.write_human_readable_gedi_headers_to_file(gedi_headers, directory, filename)
    File.open(File.join(directory, filename), "w") do |new|
      new.write("DOCUMENT EXCHANGE FORMAT INFORMATION\n")
      new.write("Exchange format:  #{gedi_headers["IFID"]}\n")
      new.write("Exchange version:  #{gedi_headers["IFVR"]}\n")
      new.write("Cover length:  #{gedi_headers["CILN"]}\n")
      new.write("Document format:  #{gedi_headers["DFID"]}\n")
      new.write("Service string:  #{gedi_headers["SSAD"]}\n")
      new.write("\n")
      new.write("DESTINATION AND STORAGE INFORMATION\n")
      new.write("Destination:  #{gedi_headers["CNSN"]}\n")
      new.write("Record name:  #{gedi_headers["RCNM"]}\n")
      new.write("Source:  #{gedi_headers["SPLN"]}\n")
      new.write("Service date/time:  #{gedi_headers["SVDT"]}\n")
      new.write("\n")
      new.write("ELECTRONIC DELIVERY TRANSACTION INFORMATION\n")
      new.write("Patron name: #{gedi_headers["CLNT"]}\n")  
      new.write("Supplier name:  #{gedi_headers["RSNM"]}\n")
      new.write("Copyright comp.:  #{gedi_headers["CPRT"]}\n")
      new.write("\n")
      new.write("DOCUMENT DESCRIPTION\n")
      new.write("Number of pages:  #{gedi_headers["NMPG"]}\n")
    end
  end

  # strips GEDI headers from a value.
  def self.remove_gedi_headers_from_file(directory, filename)

    # CILN is the gedi MNEM that specifies the cover information length
    # This is the part of the file that contains all gedi information
    ciln = parse_gedi_headers(directory, filename)["CILN"].to_i

    tempfilename = Gedi_utilities.generate_gedi_file_name(APP_CONFIG['ftp_ipaddress'], '100')

    tmppath = File.join(directory, tempfilename)
    
    ciln = parse_gedi_headers(directory, filename)["CILN"].to_i

    file = File.new(directory + "/" + filename, "r")

    File.open(tmppath, "w") do |new|
      a = file.gets

      new.puts(a[ciln..-1])
      while a = file.gets
        new.puts(a)
      end
    end
    
    File.delete(directory + "/" + filename)
    File.rename(directory + "/" + tempfilename, directory + "/" + filename)

    filename
  end
  
  # sends a file through ftp.  while this method does not specifically use gedi-specific
  # information, the ftpaddress will be present in the CLNT header
  def self.ftp_send(ftpaddress, portnumber, directory, filename, username, password)

    # try passive, if that doesn't work, try active

    begin  
      ftp=Net::FTP.new    
      ftp.passive = true
      ftp.connect(ftpaddress, portnumber)
      puts "connected to #{ftpaddress} #{portnumber} through passive mode"
      Rails.logger.info "connected to #{ftpaddress} #{portnumber} through passive mode"
      ftp.login(username, password)
      puts "credentials to #{ftpaddress} #{portnumber} valid"
      Rails.logger.info "credentials to #{ftpaddress} #{portnumber} valid"
      ftp.putbinaryfile(File.join(directory, filename))     
      puts "file transfer successful to #{ftpaddress} #{portnumber} through passive mode" 
      Rails.logger.info "file transfer successful to #{ftpaddress} #{portnumber} through passive mode" 
      
      ftp.close
      return true
    rescue Exception => exc
      puts "passive ftp to #{ftpaddress} #{portnumber} failed: #{exc.message}"
      Rails.logger.info "passive ftp to #{ftpaddress} #{portnumber} failed: #{exc.message}"
      begin 
        puts "trying active mode to to #{ftpaddress} #{portnumber}"
        Rails.logger.info "trying active mode to to #{ftpaddress} #{portnumber}"
        ftp=Net::FTP.new    
        ftp.passive = false
        ftp.connect(ftpaddress, portnumber)
        puts "connected to #{ftpaddress} #{portnumber} through active mode"
        Rails.logger.info "connected to #{ftpaddress} #{portnumber} through active mode"
        ftp.login(username, password)
        puts "credentials to #{ftpaddress} #{portnumber} valid" 
        Rails.logger.info "credentials to #{ftpaddress} #{portnumber} valid"    
        ftp.putbinaryfile(File.join(directory, filename)) 
        puts "file transfer successful to #{ftpaddress} #{portnumber} through active mode" 
        Rails.logger.info "file transfer successful to #{ftpaddress} #{portnumber} through active mode"
        ftp.close
        return true
      rescue Exception => esc
         puts "active and passive ftp to #{ftpaddress} #{portnumber} failed: #{exc.message}"
         Rails.logger.info "active and passive ftp to #{ftpaddress} #{portnumber} failed: #{exc.message}"
         ftp.close 
         return false
      end   
    end
  end  
end