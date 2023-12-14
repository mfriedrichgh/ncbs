class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :creator
      t.boolean :public
      t.datetime :created
      t.string :repo

      t.timestamps
    end
  end
end
