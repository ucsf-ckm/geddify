class AddFilenameToGedifile < ActiveRecord::Migration
  def change
    add_column :gedifiles, :filename, :string
  end
end
