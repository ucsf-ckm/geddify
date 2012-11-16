class AddGedifileIdToGedifilename < ActiveRecord::Migration
  def change
    add_column :gedifilenames, :gedifile_id, :integer
  end
end
