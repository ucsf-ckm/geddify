class AddGedifilenameIdToAccesshistory < ActiveRecord::Migration
  def change
    add_column :accesshistories, :gedifilename_id, :integer
  end
end
