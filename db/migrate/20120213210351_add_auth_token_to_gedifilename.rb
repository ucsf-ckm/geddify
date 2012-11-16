class AddAuthTokenToGedifilename < ActiveRecord::Migration
  def change
    add_column :gedifilenames, :auth_token, :string
  end
end
