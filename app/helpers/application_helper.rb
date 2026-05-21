module ApplicationHelper
  def todo_desire_to_work_class(todo)
    value = todo.desire_to_work.to_s.gsub(/\./, "-")
    "todo-desire-to-work--normal--#{value}"
  end

  def abbr(value)
    {
      1 => 'L',
      2 => 'ML',
      3 => 'M',
      4 => 'MH',
      5 => 'H',
    }[value]
  end
end
