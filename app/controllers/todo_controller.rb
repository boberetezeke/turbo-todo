class TodoController < ApplicationController
  def index
    @todos = ordered_todos
    @new_todo = Todo.new
  end

  def create
    @new_todo = Todo.new(todo_params)

    if @new_todo.save
      @created_todo = @new_todo
      @new_todo = Todo.new

      respond_to do |format|
        format.html { redirect_to root_path }
        format.turbo_stream { render :create, status: :created }
      end
    else
      @todos = ordered_todos

      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.turbo_stream { render :create, status: :unprocessable_entity }
      end
    end
  end

  private

  def ordered_todos
    Todo.order(:id)
  end

  def todo_params
    params.require(:todo).permit(:title)
  end
end