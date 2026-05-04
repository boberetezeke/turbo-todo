class TestsController < ApplicationController
  def reset
    if ENV["TEST_RESET_KEY"] && params[:key] == ENV["TEST_RESET_KEY"]
      Todo.delete_all
      head :ok
    else
      head :forbidden
    end
  end
end