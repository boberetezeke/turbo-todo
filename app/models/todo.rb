class Todo < ActiveRecord::Base
  validates :title, presence: true
  validates :order, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def move_to_order!(target_order)
    normalized_order = [target_order.to_i, 1].max
    order_column = self.class.connection.quote_column_name(:order)

    self.class.transaction do
      self.class
        .where.not(id: id)
        .where("#{order_column} >= ?", normalized_order)
        .update_all("#{order_column} = #{order_column} + 1")

      update!(order: normalized_order)
    end
  end

  def complete
    update(completed_at: Time.now)
  end

  def uncomplete
    update(completed_at: nil)
  end

  def completed?
    completed_at.present?
  end

  def deleted?
    deleted_at.present?
  end

  def desire_to_work
    self.class.desire_to_work(difficulty, severity)
  end

  def deadline_danger
    return 0 unless deadline

    self.class.deadline_danger(deadline_type, deadline, difficulty)
  end

  def self.desire_to_work(difficulty, severity)
    ((4 - (difficulty - severity)) / 2.0) + 1
  end

  def self.deadline_danger(deadline_type, deadline, difficulty)
    val = (((deadline.to_date - Time.now.to_date) - 1) / difficulty).floor + 1
    val = 1 if val < 1
    val = 4 if val > 3
    4 - val
  end
end