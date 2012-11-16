class RemoveFilenameFromGedifile < ActiveRecord::Migration
  def up
    remove_column :gedifiles, :filename
  end

  def down
    add_column :gedifiles, :filename, :string
  end
end
