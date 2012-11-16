class CreateAccesshistories < ActiveRecord::Migration
  def change
    create_table :accesshistories do |t|
      t.string :action

      t.timestamps
    end
  end
end
