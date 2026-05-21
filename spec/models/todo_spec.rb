require 'rails_helper'

#                         Severity
#                 |  1  |  2  |  3  |  4  |  5  |
# Difficulty      +-----------------------------
#               1 |  3  |3.50 |  4  |4.50 |  5  |
#               2 |2.50 |  3  |3.50 |  4  |4.50 |
#               3 |  2  |2.50 |  3  |3.50 |  4  |
#               4 |1.50 |  2  |2.50 |  3  |3.50 |
#               5 |  1  |1.50 |  2  |2.50 |  3  |
# desire_to_work(difficulty, severity) = (4 - (difficulty - severity) / 2.0)) + 1
describe Todo do
  describe "#desire_to_work" do
    it "when least difficult and least severe, it is less than half desirable" do
      todo = Todo.new(difficulty: 1, severity: 5)
      expect(todo.desire_to_work).to eq(5.0)
    end

    it "when mid difficult and mid severe, it is less than half desirable" do
      todo = Todo.new(difficulty: 3, severity: 3)
      expect(todo.desire_to_work).to eq(3.0)
    end

    it "when most difficult and most severe, it is less than half desirable" do
      todo = Todo.new(difficulty: 5, severity: 5)
      expect(todo.desire_to_work).to eq(3.0)
    end

    it "when most difficult and least severe, it is very undesirable" do
      todo = Todo.new(difficulty: 1, severity: 1)
      expect(todo.desire_to_work).to eq(3.0)
    end

    it "when least difficult and most severe, it is very desirable" do
      todo = Todo.new(difficulty: 5, severity: 1)
      expect(todo.desire_to_work).to eq(1.0)
    end
  end
end