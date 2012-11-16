class CreateGedifilenames < ActiveRecord::Migration
  def change
    create_table :gedifilenames do |t|
      t.string :filename

      t.timestamps
    end
  end
end
