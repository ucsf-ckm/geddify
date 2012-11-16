require 'active_support/secure_random'
require 'net/ftp'
require "uri"
require "net/http"
require 'net/http/post/multipart'


class Gedifile < ActiveRecord::Base
  
  has_one :gedifilename
        
  validates_presence_of :IFID
  validates_length_of :IFID, :maximum=>30  

  validates_presence_of :IFVR
  validates_length_of :IFVR, :maximum=>20
  
  validates_presence_of :CILN
  validates_length_of :CILN, :maximum=>10
  validates_numericality_of :CILN, :only_integer => true, :less_than_or_equal_to => 2048
  
  validates_presence_of :DFID
  validates_length_of :DFID, :maximum=>20  
  
  # SSAD is a mandatory GEDI header, but it is not present in Ariel3, so we have
  # to make it optional
  #validates_presence_of :SSAD
  validates_length_of :SSAD, :maximum=>50
  
  validates_presence_of :CNSN
  validates_length_of :CNSN, :maximum=>250
  
  validates_presence_of :RCNM
  validates_length_of :RCNM, :maximum=>32
  
  validates_presence_of :SPLN
  validates_length_of :SPLN, :maximum=>250
  
  validates_presence_of :SVDT
  validates_length_of :SVDT, :maximum=>14
  
  # return the client address
  # this value indicates where the gedi file
  # should be sent through ftp
  def getclientaddress 
    if self.CNSN.include?('A=')
      clientaddress = self.CNSN.split('A=')[1]
      clientaddress[0,clientaddress.index(')')]
    else
      nil
    end
  end
  
  # returns the server address
  # this is the ip address of the serve that 
  # recieved this document
  def getserveraddress
      if self.SPLN.include?('A=')
        serveraddress = self.SPLN.split('A=')[1]
        if serveraddress.include?(';')
          serveraddress[0, serveraddress.index(';')]
        else
          serveraddress[0, serveraddress.length-1]
        end
      else
        nil
      end
  end
  
  # return the email address, if present
  # this will indicate which patron will 
  # recieve an email notification and download link
  def get_client_email_address 
    
    client_email_address = nil
    
    if self.CNSN.include?('E=')
      cnsns = self.CNSN.split(";") 
    
      cnsns.each { |el|
        if el.include?('E=')
            client_email_address = el[2.. -1]
        end }
    end
    
    client_email_address
  end
  
  # Match the DFID gedi header to a file extension
  def get_file_extension
    # support TIFF, JPEG, PDF, GIF, BMP
    if self.DFID.include?('TIF') || self.DFID.include?('TIFF')
      'tif'
    elsif self.DFID.include?("JPEG")
      'jpeg'
    elsif self.DFID.include?("PDF")
      'pdf'
    elsif self.DFID.include?("GIF")
      'gif'
    elsif self.DFID.include?("BMP")
      'bmp'
    else
      nil
    end
  end
  
  # Set the DFID gedi header based on file extension
  def set_file_extension(extension)
    # support TIFF, JPEG, PDF, GIF, BMP
    if extension.include?('.tif') || extension.include?('.tiff')
      self.DFID = 'TIFF'
    elsif extension.include?(".jpeg")
      self.DFID = 'JPEG'
    elsif extension.include?(".pdf")
      self.DFID = 'PDF'
    elsif extension.include?(".gif")
      self.DFID = 'GIF'
    elsif extension.include?(".bmp")
      self.DFID = 'BMP'
    else
      nil
    end
  end
    
  
  # convert a hash of gedi header/value pairs
  # to a gedifile object
  # note that the gedifile attributes will match
  # the headers in the hash
  def populate_from_gedi_headers(gedi_headers)    
    gedi_headers.each_pair do |k, v| 
      unless k == ''
        # TODO look a way to do this without eval
        eval("self.#{k} = gedi_headers[\"#{k}\"]")
      end
    end
  end
  
  # send a gedifile through ftp to a remote server
  def send_via_ftp(port, username, password)    
    begin
      # send the file through active mode
      if Gedi_utilities.ftp_send(self.getclientaddress, port, APP_CONFIG['gedifiles_directory'], self.gedifilename.filename, username, password)
        self.gedifilename.status = "sent"
        self.gedifilename.save
        update_access_history("ftp to #{self.getclientaddress}", self.gedifilename.id)
        return true
      else
        self.gedifilename.status = "failed"
        self.gedifilename.save
        update_access_history("Error: ftp to #{self.getclientaddress} failed", self.gedifilename.id)
        return false
      end
    rescue Exception => exc
      self.gedifilename.status = "failed"
      self.gedifilename.save
      update_access_history("Error: ftp to #{self.getclientaddress} failed", self.gedifilename.id)
      return false
    end
  end
  
  def self.import_gedi_file(upload)
      name =  upload.original_filename
      directory = APP_CONFIG['gedifiles_directory']
            
      path = File.join(directory, name)
      
      File.open(path, "wb") { |f| f.write(upload.read) }
      
      gedi_headers = Gedi_utilities.parse_gedi_headers(directory, name)
      
      if gedi_headers.nil?
        return nil
      else      
        gedifile = Gedifile.new
      
        gedifile.populate_from_gedi_headers(gedi_headers)
        gedifile.save!
      
        gedifilename = Gedifilename.new
        
        gedifilename.status = "pending"
        
        gedifilename.gedifile_id = gedifile.id
        gedifilename.save
        
        gedifilename.filename = Gedi_utilities.generate_gedi_file_name(APP_CONFIG['ftp_ipaddress'], gedifilename.id)
        gedifilename.generate_token
        gedifilename.save
        
        File.rename("#{APP_CONFIG['gedifiles_directory']}/" + name, "#{APP_CONFIG['gedifiles_directory']}/" + gedifilename.filename)

        return gedifile
      end
  end
  
  def delete_gedi_file
    
    if File.exists?("#{APP_CONFIG['gedifiles_directory']}/" + self.gedifilename.filename)
      File.delete("#{APP_CONFIG['gedifiles_directory']}/" + self.gedifilename.filename)
    end
    self.delete
    self.gedifilename.delete
        
  end
  
  # convert the IP address to a hex string
  # ariel uses a unique authentication system that accepts a hashed version of the 
  # IP address as a password.  This method will provide the IP address
  def hash_ip_address
    # server address refers to the server hosting this rails app
    ("%02X%02X%02X%02X" % self.getserveraddress.split('.')).gsub('0', '#')
  end
  
  # Read the gedifiles residing in the ftp server, import them to the local
  # filesystem, update the database, and remove them from the ftp server
  def self.ingest_ftp_files(ipaddress, port, username, password)
    ftp=Net::FTP.new
    #ftp.passive = true

    begin 
      ftp.connect(ipaddress, port)
      ftp.login(username, password)

      files = ftp.list('-t *')
    
      files.each do |f|
        name = f.split(" ")[-1]

        unless Gedifilename.exists?(:filename => name)
          ftp.getbinaryfile(name, 'gedifiles/' + name)

          directory = "gedifiles"
        
          @gedifile = Gedifile.new
        
          gedi_headers = Hash.new
        
          gedi_headers = Gedi_utilities.parse_gedi_headers('gedifiles', name)
        
          if !gedi_headers.nil?
        
            @gedifile.populate_from_gedi_headers(gedi_headers)
            @gedifile.save
        
            @gedifilename = Gedifilename.new
            @gedifilename.filename = name
            @gedifilename.status = "pending"
            @gedifilename.gedifile = @gedifile
            @gedifilename.generate_token
            @gedifilename.save
        
            ftp.delete(name)
          end
        
        end
      end
    
    ftp.close
    true
    
    rescue Exception => exc
      puts exc.message
      ftp.close
      false
    end

  end
  
  # the gedifile attributes correspond to the names of the gedi headers
  # however, a few attributes do not match.  this method removes them from
  # a hash of the gedifile attribute/value pairs
  def get_gedi_attributes
    gedi_headers = self.attributes
    gedi_headers.delete("id")
    gedi_headers.delete("created_at")
    gedi_headers.delete("updated_at")
    gedi_headers.delete("lock_version")
    # ZPAD is a generated value, so we will not have it set in the view
    gedi_headers.delete("ZPAD")
    
    gedi_headers
  end
  
  def set_preconfig_headers(target_type, address)
    case target_type
    when 'patron'
      self.set_mandatory_headers(address)
    when 'ariel3ftp'
      self.set_ariel3_headers(address)
    when 'ariel3email'
      self.set_ariel3_headers(address)
    when 'ariel4ftp'
      self.set_ariel4_headers(address)
    when 'ariel4email'
      self.set_ariel4_headers(address)
    when 'geddify'
      self.set_mandatory_headers(address)
    when 'none'
      self.set_mandatory_headers(address)
    end
  end
  
  def set_mandatory_headers(address)
    self.IFID = GEDI_CONFIG['IFID']
    self.IFVR = GEDI_CONFIG['IFVR']
    self.CILN = GEDI_CONFIG['CILN']
    self.DFID = GEDI_CONFIG['DFID']   
    self.SSAD = GEDI_CONFIG['SSAD']
    self.CNSN = "N=Ariel/Windows;F=(A=#{address})"
    self.RCNM = GEDI_CONFIG['RCNM']
    self.SPLN = GEDI_CONFIG['SPLN']
    self.RSNM = GEDI_CONFIG['RSNM']
    self.RSNT = GEDI_CONFIG['RSNT']
    self.NMPG = GEDI_CONFIG['NMPG']
    self.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
  end
  
  def set_ariel3_headers(address)
    self.IFID = GEDI_CONFIG['IFID']
    self.IFVR = GEDI_CONFIG['IFVR']
    self.CILN = GEDI_CONFIG['CILN']
    self.DFID = GEDI_CONFIG['DFID']
    self.CNSN = "N=Ariel/Windows;F=(A=#{address})"
    self.RCNM = GEDI_CONFIG['RCNM']
    self.SPLN = GEDI_CONFIG['SPLN']
    self.RSNM = GEDI_CONFIG['RSNM']
    self.CPRT = GEDI_CONFIG['CPRT']
    self.NMPG = GEDI_CONFIG['NMPG']
    self.CLNT = GEDI_CONFIG['CLNT']

    self.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
  end
  
  def set_ariel4_headers(address)
    
    self.IFID = GEDI_CONFIG['IFID']
    self.IFVR = GEDI_CONFIG['IFVR']
    self.CILN = GEDI_CONFIG['CILN']
    self.DFID = GEDI_CONFIG['DFID']   
    self.SSAD = GEDI_CONFIG['SSAD']
    self.CNSN = "N=Ariel/Windows;F=(A=#{address})"
    self.RCNM = GEDI_CONFIG['RCNM']
    self.SPLN = GEDI_CONFIG['SPLN']
    self.CLNT = GEDI_CONFIG['CLNT']
    self.RSNM = GEDI_CONFIG['RSNM']
    self.RSNT = GEDI_CONFIG['RSNT']
    self.NMPG = GEDI_CONFIG['NMPG']
    
    self.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
  end
  
  def send_forward(address, target_type)
    
    @gedifilename = self.gedifilename       
    self.SPLN = GEDI_CONFIG['SPLN']
           
    if target_type == 'patron'
      self.CNSN = "N=Ariel/Windows;E=#{address}"
      return send_email_to_patron(address)
    elsif target_type == 'geddify'
      self.CNSN = "N=Ariel/Windows;F=(A=#{address})"
      self.send_via_geddify(address)
    elsif target_type == 'ariel3ftp'
      self.CNSN = "N=Ariel/Windows;F=(A=#{address})"
      self.send_via_ftp(APP_CONFIG['ftp_port'], "document", self.hash_ip_address)    
    elsif target_type == 'ariel3email'
      self.CNSN = "N=Ariel/Windows;E=#{address}"
      return send_email_to_ariel_server(self.get_gedi_attributes, address)
    elsif target_type == 'ariel4ftp'
      self.CNSN = "N=Ariel/Windows;F=(A=#{address})"
      return self.send_via_ftp(APP_CONFIG['ftp_port'], "ariel4", self.hash_ip_address)   
    elsif target_type == 'ariel4email'
      self.CNSN = "N=Ariel/Windows;E=#{address}"
      return send_email_to_ariel_server(self.get_gedi_attributes, address)
    elsif target_type == 'none'
      return true
    else
      return false
    end
  end
  
  def upload_gedi_file(upload, address, target_type)
    directory = APP_CONFIG['gedifiles_directory']
    name = upload['gedifile'].original_filename
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(upload['gedifile'].read) }  

    # only gedi attributes should be added to file
    # so remove the non-gedi attributes from the hash before 
    # adding all model attribute/value pairs to the headers
    gedi_headers = self.get_gedi_attributes

    Gedi_utilities.add_gedi_headers_to_file(gedi_headers, directory, name)

    @gedifilename = Gedifilename.new

    @gedifilename.gedifile_id = self.id
    @gedifilename.status = "pending"
    @gedifilename.generate_token
    @gedifilename.save    
    
    @gedifilename.filename = Gedi_utilities.generate_gedi_file_name(APP_CONFIG['ftp_ipaddress'], @gedifilename.id)
    File.rename(directory + "/" + name, directory + "/" + @gedifilename.filename)
    
    @gedifilename.save

    if !target_type.nil?
      self.send_forward(address, target_type)
    else  
      return true
    end
  
  end
    
  def update_gedi_file
    begin
      Gedi_utilities.remove_gedi_headers_from_file(APP_CONFIG['gedifiles_directory'], self.gedifilename.filename)
      Gedi_utilities.add_gedi_headers_to_file(@gedifile.get_gedi_attributes , APP_CONFIG['gedifiles_directory'],self.gedifilename.filename)
      return true
    rescue Exception => exc
      Rails.logger.info exc
      return false
    end  
  end  
    
  def send_via_geddify(address)
    # Token used to terminate the file in the post body. Make sure it is not
    # present in the file you're uploading.
 
    begin
 
      url = URI.parse('http://' + address + '/import_gedi_file')
 
      File.open(APP_CONFIG['gedifiles_directory'] + "/" + self.gedifilename.filename) do |f|
        req = Net::HTTP::Post::Multipart.new url.path,
          "gedifile" => UploadIO.new(f, "image/#{self.get_file_extension}")
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
      end
      
      self.gedifilename.status = "sent"
      self.gedifilename.save
      return true
    
    rescue Exception => exc
      Rails.logger.info exc
      
      update_access_history("send to geddify failed " + address, self.gedifilename.id)
      
      self.gedifilename.status = "failed"
      self.gedifilename.save
      
      return false
    end
    
  end
  
  private
  
  def update_access_history(event, id)
    accesshistory = Accesshistory.new
    accesshistory.action = event
    accesshistory.gedifilename_id = id
    accesshistory.save!
  end  
  
  # mailing to a server rather than a patron
  # we will need three attachments
  # DOCINFO.GDI - which is the gedi headers only
  # DOCINFO.txt - gedi headers in human readable format
  # DOCUMENT.tif (or whatever extension is available)
  def send_email_to_ariel_server(gedi_headers, address)
    
    begin
      if !address.include?('@')
        update_access_history("email failed, #{address} not a valid email address", self.gedifilename.id)    
      end
        
      directory = APP_CONFIG['gedifiles_directory']

      # create the DOCINFO.GDI header
      file = File.new(File.join(directory, "DOCINFO.GDI"), "w+")
      Gedi_utilities.add_gedi_headers_to_file(gedi_headers, directory, "DOCINFO.GDI")    

      # create the DOCINFO.txt human readable file
      Gedi_utilities.write_human_readable_gedi_headers_to_file(gedi_headers, directory, "DOCINFO.txt")    

      # create the DOCUMENT (no gedi headers)
      FileUtils.cp "#{APP_CONFIG['gedifiles_directory']}/" + self.gedifilename.filename, "#{APP_CONFIG['gedifiles_directory']}/DOCUMENT" + "." + self.gedifilename.gedifile.get_file_extension
      Gedi_utilities.remove_gedi_headers_from_file(APP_CONFIG['gedifiles_directory'], 'DOCUMENT' + "." + self.gedifilename.gedifile.get_file_extension)

      update_access_history("emailed to server #{address}", self.gedifilename.id)    
      GediMailer.send_to_server(self).deliver
      file.close
            
      return true
    rescue Exception => exc
      Rails.logger.info exc
      return false
    end
  end
  
  def send_email_to_patron(address)
     GediMailer.delivery_confirmation(self).deliver
     update_access_history("emailed to #{address}", self.gedifilename.id)
  end
  
end
