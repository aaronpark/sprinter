class AddUpdateAndCreateToCards < ActiveRecord::Migration
  def change
    add_column :cards, :card_created, :timestamp
    add_column :cards, :card_updated, :timestamp
  end
end
