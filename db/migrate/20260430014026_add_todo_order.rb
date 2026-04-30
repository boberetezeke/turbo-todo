class AddTodoOrder < ActiveRecord::Migration[8.1]
  def change
    add_column :todos, :order, :integer, null: false
  end
end
