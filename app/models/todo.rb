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

  def completed?
    completed_at.present?
  end

  def deleted?
    deleted_at.present?
  end
end