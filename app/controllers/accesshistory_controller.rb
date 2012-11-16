class AccesshistoryController < ApplicationController
  
  def list
    @accesshistories = Accesshistory.find_all_by_gedifilename_id(params[:id], :include=>[:gedifilename])
    @gedifilename = Gedifilename.find_by_id(params[:id])
  end
  
end
