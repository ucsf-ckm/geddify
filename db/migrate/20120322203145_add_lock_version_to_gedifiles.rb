class AddLockVersionToGedifiles < ActiveRecord::Migration
  def change
    add_column :gedifiles, :lock_version, :integer, :default => 0, :null => false
  end
end
