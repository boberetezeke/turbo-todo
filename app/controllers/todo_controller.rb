class TodoController < ApplicationController
  def index
    @todos = ordered_todos
    @new_todo = Todo.new
  end

  def create
    @new_todo = Todo.new(todo_params)
    highest_order = Todo.maximum(:order) || 0
    @new_todo.order = highest_order + 1

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
        format.html { render :index, status: :unprocessable_content }
        format.turbo_stream { render :create, status: :unprocessable_content }
      end
    end
  end

  def update
    @todo = Todo.find(params[:id])
    @todo.move_to_order!(todo_order_param)
    @todos = ordered_todos

    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream
      format.json { head :ok }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { redirect_to root_path, alert: "Unable to reorder todo." }
      format.turbo_stream { head :unprocessable_content }
      format.json { head :unprocessable_content }
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    @todo.destroy
    @todos = ordered_todos

    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream
    end
  end

  private

  def ordered_todos
    Todo.order(order: :asc)
  end

  def todo_params
    params.require(:todo).permit(:title, :difficulty, :severity)
  end

  def todo_order_param
    params.require(:todo).permit(:order).fetch(:order).to_i
  end
end