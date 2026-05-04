class AddDifficultyAndSeverity < ActiveRecord::Migration[8.1]
  def change
    add_column :todos, :severity, :integer
    add_column :todos, :difficulty, :integer
  end
end
