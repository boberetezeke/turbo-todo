class AddEventAts < ActiveRecord::Migration[8.1]
  def change
    add_column :todos, :deleted_at, :datetime
    add_column :todos, :completed_at, :datetime
  end
end
