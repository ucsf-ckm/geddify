class AddStatusToGedifilename < ActiveRecord::Migration
  def change
    add_column :gedifilenames, :status, :string
  end
end
