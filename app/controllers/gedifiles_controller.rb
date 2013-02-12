require 'socket'
require 'net/ftp'

class GedifilesController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate, :only => [:import_gedi_file, :file_download_page, :file_download]

  def index
    if !params[:status].nil?
      @gedifilenames = Gedifilename.find_all_by_status(params[:status], :include=>[:gedifile])
    else
      @gedifilenames = Gedifilename.all(:include=>[:gedifile])
    end
  end

  # sync with the external ftp server
  # this will import all gedi files to the local gedifiles directory
  # and update the application database with the gedi headers and file information
  def ftp_sync
    Gedifile.ingest_ftp_files(APP_CONFIG['ftp_ipaddress'], APP_CONFIG['ftp_port'], APP_CONFIG['ftp_username'], APP_CONFIG['ftp_password'])
    @gedifilenames = Gedifilename.all
     
    redirect_to '/gedifiles/pending/list'
  end

  # mandatory gedi fields only
  def new
    @gedifile = Gedifile.new
    @gedifile.set_mandatory_headers(APP_CONFIG['ftp_ipaddress'])
    
    @gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
  end
  
  def short
    @gedifile = Gedifile.new
  end
  
  def forward
    @gedifile = Gedifile.find(params[:id])
    @gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
  end
  
  def send_forward
    @gedifile = Gedifile.find(params[:id])
    if(params[:address].nil?)
      flash[:notice] = "address required"
    elsif(params[:target_type].nil?)
      flash[:notice] = "target type required"
    else 
    
      if @gedifile.send_forward(params[:address], params[:target_type])
        flash[:notice] =  "Success: #{@gedifile.gedifilename.filename} sent to #{params[:target_type]} #{params[:address]}"
      else
        flash[:notice] = "Error: #{@gedifile.gedifilename.filename} not sent to #{params[:target_type]} #{params[:address]}"
      end
            
    end
    redirect_to request.referer and return
  end
  
  # required gedi headers for ariel3
  def ariel3
    @gedifile = Gedifile.new
    @gedifile.set_ariel3_headers(APP_CONFIG['ftp_ipaddress'])
  end
  
  # required gedi headers for ariel4
  def ariel4
    @gedifile = Gedifile.new
    @gedifile.set_ariel4_headers(APP_CONFIG['ftp_ipaddress'])
  end
  
  # all gedi headers (only mandatory ones are pre-filled)
  def longform
    @gedifile = Gedifile.new
    @gedifile.set_mandatory_headers(APP_CONFIG['ftp_ipaddress'])
    
    @attributes = @gedifile.get_gedi_attributes 
  end
  
  def edit
    @gedifile = Gedifile.find(params[:id])
    @gedifile.SVDT = Time.now.strftime("%Y%m%d%H%M%S")
  end
  
  def editlongform
    @gedifile = Gedifile.find(params[:id])
    @attributes = @gedifile.get_gedi_attributes 
  end
  
  def update
    @gedifile = Gedifile.find(params[:id])
      
    if @gedifile.update_attributes(params[:gedifile])
      if @gedifile.update_gedi_file
        flash[:notice] = "Success: #{@gedifile.gedifilename.filename} update succeeded"
      else
        flash[:notice] = "Error: #{@gedifile.gedifilename.filename} update failed"
      end
        
      redirect_to request.referer and return
    else 
      render :action => "new"
    end
  end
  
  def import 
  end
  
  def create
    @gedifile = Gedifile.new(params[:gedifile])
    
    upload = params[:upload]
    
    # upload the non-gedi file
    if (upload.nil? || upload.blank?)
      flash[:error] = "Error: No file selected"
      redirect_to request.referer and return
    end
    
    name = upload['gedifile'].original_filename
    
    # make sure the file extension is gedi-compliant
    if @gedifile.set_file_extension(name.scan(/\.\w+$/)).nil?
      flash[:error] = "Invalid file extension"
      redirect_to request.referer and return
    end
     
    # if this is a quick send, fill in with ariel specific gedi headers
    if !params[:address].nil? && !params[:target_type].nil?
      
      if params[:address].blank?
        flash[:error] = "No ip or email address selected"
        redirect_to request.referer and return
      end
      
      # set gedi headers specific to target type (ariel3, ariel4, geddify)
      @gedifile.set_preconfig_headers(params[:target_type], params[:address])
    end
      
    if @gedifile.save
     if @gedifile.upload_gedi_file(upload, params[:address], params[:target_type])
       flash[:notice] = "Success: #{@gedifile.gedifilename.filename} created"
     else
       flash[:notice] = "Error: #{@gedifile.gedifilename.filename}, see logs"
     end
     redirect_to request.referer and return
    else
      render action: "new"
    end
  end
  
  def file_download_page
    @gedifilename = Gedifilename.find_by_auth_token(params[:auth_token])
       
    if @gedifilename.nil?
      redirect_to '404.html' and return
    end
    
    render :layout => false
  end
  
  # find gedi file by auth token, remove headers, and stream it to end user
  # (this will be accessed through an email notification)
  def file_download
    @gedifilename = Gedifilename.find_by_auth_token(params[:auth_token])
    
    if  !@gedifilename.nil?
    
      update_access_history("file download", @gedifilename.id)
    
      gedi_headers = Hash.new  
      gedi_headers = Gedi_utilities.parse_gedi_headers(APP_CONFIG['gedifiles_directory'], @gedifilename.filename)
    
      Gedi_utilities.remove_gedi_headers_from_file(APP_CONFIG['gedifiles_directory'], @gedifilename.filename)
      File.rename("#{APP_CONFIG['gedifiles_directory']}/" + @gedifilename.filename, "#{APP_CONFIG['gedifiles_directory']}/" + @gedifilename.filename + "." + @gedifilename.gedifile.get_file_extension)
      
      send_file "#{APP_CONFIG['gedifiles_directory']}/" + @gedifilename.filename + "." + @gedifilename.gedifile.get_file_extension, :x_sendfile=>true
    
      File.rename("#{APP_CONFIG['gedifiles_directory']}/" + @gedifilename.filename + "." + @gedifilename.gedifile.get_file_extension, "#{APP_CONFIG['gedifiles_directory']}/" + @gedifilename.filename)
      Gedi_utilities.add_gedi_headers_to_file(gedi_headers, APP_CONFIG['gedifiles_directory'], @gedifilename.filename)
      
    else
      redirect_to '/404.html'
    end
  end
  
  # find gedi file by auth token, stream to end user with gedi headers
  def gedi_download
     @gedifilename = Gedifilename.find_by_auth_token(params[:auth_token])

      if  !@gedifilename.nil?
        update_access_history("gedi download", @gedifilename.id)
        send_file "#{APP_CONFIG['gedifiles_directory']}/" + @gedifilename.filename, :x_sendfile=>true
      else
        redirect_to '/404.html'
      end
  end
    
  # import an existing gedi file into local filesystem
  # unlike the create method, this method assumes the imported
  # file already contains valid gedi headers  
  def import_gedi_file
      
      upload = params[:gedifile]
      
      if upload.blank?
        flash[:error] = "No file selected"
        redirect_to request.referer and return
      end
      
      @gedifile = Gedifile.import_gedi_file(upload)
      
      if !@gedifile.nil? 
        flash[:notice] = "Success: #{@gedifile.gedifilename.filename} Import Complete"     
        update_access_history("imported", @gedifile.gedifilename.id)   
      else
        flash[:notice] = "Import Failed"
      end
        
      redirect_to request.referer
  end
  
  # remove record from database and delete from local filesystem
  def destroy
    @gedifile = Gedifile.find(params[:id])
    
    if @gedifile.nil?
      flash[:error] = "Error: File not found"
    else
      flash[:notice] = "#{@gedifile.gedifilename.filename} deleted"
      @gedifile.delete_gedi_file
    end

    redirect_to request.referer
  end
  
  private
  
  def update_access_history(event, id)
    accesshistory = Accesshistory.new
    accesshistory.action = event
    accesshistory.gedifilename_id = id
    accesshistory.save!
  end
  
end