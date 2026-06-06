class AddDeadline < ActiveRecord::Migration[8.1]
  def change
    add_column :todos, :deadline, :datetime
    add_column :todos, :deadline_type, :string, default: 'time', null: false
  end
end
