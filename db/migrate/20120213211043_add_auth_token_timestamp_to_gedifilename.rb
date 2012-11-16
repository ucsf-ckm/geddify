class AddAuthTokenTimestampToGedifilename < ActiveRecord::Migration
  def change
    add_column :gedifilenames, :auth_token_timestamp, :date
  end
end
