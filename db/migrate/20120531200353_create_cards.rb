class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :summary
      t.text :description
      t.string :assignee
      t.integer :points
      t.string :status
      t.string :key
      t.integer :sprint_id
      t.string :type

      t.timestamps
    end
  end
end
