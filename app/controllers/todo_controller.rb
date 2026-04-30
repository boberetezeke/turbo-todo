class TodoController < ApplicationController
  def index
    @todos = Todo.all
    @new_todo = Todo.new
  end
end