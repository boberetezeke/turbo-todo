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

  describe '#deadline_danger' do
    subject { Todo.new(difficulty: difficulty, severity: 1, deadline_type: 'date', deadline: Time.now.to_date + days_in_future)}

    context 'when difficulty one' do
      let(:difficulty) { 1 }
      # for difficulty 1
      # 1 day left -  danger 3
      # 2 days left - danger 2
      # 3 days left - danger 1
      # 4 days left - danger 0
      # 5 days left - danger 0
      context 'when 1 day left' do
        let(:days_in_future) { 1 }

        it 'when most severe' do
          expect(subject.deadline_danger).to eq(3)
        end
      end

      context 'when 2 days left' do
        let(:days_in_future) { 2 }

        it 'when most severe' do
          expect(subject.deadline_danger).to eq(2)
        end
      end

      context 'when 3 days left' do
        let(:days_in_future) { 3 }

        it 'when most severe' do
          expect(subject.deadline_danger).to eq(1)
        end
      end

      context 'when 4 days left' do
        let(:days_in_future) { 4 }

        it 'when most severe' do
          expect(subject.deadline_danger).to eq(0)
        end
      end

      context 'when 5 days left' do
        let(:days_in_future) { 5 }

        it 'when most severe' do
          expect(subject.deadline_danger).to eq(0)
        end
      end
    end

    context 'when difficulty three' do
      let(:difficulty) { 3 }
      # for difficulty 3
      #
      # 1 day left -  danger 3
      # 3 days left - danger 3
      # 4 days left - danger 2
      # 6 days left - danger 2
      # 7 days left - danger 1
      # 9 days left - danger 1
      # 10 days left - danger 0
      # 15 days left - danger 0

      context 'when 1 day left' do
        let(:days_in_future) { 1 }

        it 'when most severe' do
          expect(subject.deadline_danger).to eq(3)
        end
      end

      context 'when 3 days left' do
        let(:days_in_future) { 3 }

        it 'when most severe' do
          expect(subject.deadline_danger).to eq(3)
        end
      end

      context 'when 4 days left' do
        let(:days_in_future) { 4 }

        it 'when most severe' do
          expect(subject.deadline_danger).to eq(2)
        end
      end

      context 'when 6 days left' do
        let(:days_in_future) { 6 }

        it 'when most severe' do
          expect(subject.deadline_danger).to eq(2)
        end
      end

      context 'when 7 days left' do
        let(:days_in_future) { 7 }

        it 'it is least severe' do
          expect(subject.deadline_danger).to eq(1)
        end
      end

      context 'when 9 days left' do
        let(:days_in_future) { 9 }

        it 'it is least severe' do
          expect(subject.deadline_danger).to eq(1)
        end
      end

      context 'when 10 days left' do
        let(:days_in_future) { 10 }

        it 'it is not severe' do
          expect(subject.deadline_danger).to eq(0)
        end
      end

      context 'when 15 days left' do
        let(:days_in_future) { 15 }

        it 'it is not severe' do
          expect(subject.deadline_danger).to eq(0)
        end
      end
    end
  end
end