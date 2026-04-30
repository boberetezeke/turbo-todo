require "rails_helper"

RSpec.describe "Todos", type: :request do
  describe "POST /todo" do
    it "redirects back to the index for a regular HTML submission" do
      expect do
        post todo_index_path, params: { todo: { title: "Walk the dog" } }
      end.to change(Todo, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)

      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Walk the dog")
    end

    it "appends a todo and resets the form for a Turbo Stream submission" do
      expect do
        post todo_index_path,
          params: { todo: { title: "Buy milk" } },
          as: :turbo_stream
      end.to change(Todo, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include(%(action="append" target="todos"))
      expect(response.body).to include(%(action="replace" target="new_todo"))
      expect(response.body).to include("Buy milk")
    end

    it "replaces the form with errors for an invalid Turbo Stream submission" do
      expect do
        post todo_index_path,
          params: { todo: { title: "" } },
          as: :turbo_stream
      end.not_to change(Todo, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include(%(action="replace" target="new_todo"))
      expect(response.body).to match(/Title can(?:&#39;|')t be blank/)
    end
  end

  describe "PATCH /todo/:id" do
    it "renumbers todos at or above the target order and updates the dragged todo" do
      first_todo = Todo.create!(title: "First", order: 1)
      second_todo = Todo.create!(title: "Second", order: 2)
      third_todo = Todo.create!(title: "Third", order: 3)

      patch todo_path(third_todo),
        params: { todo: { order: first_todo.order } },
        as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include(%(action="replace" target="todos"))

      expect(first_todo.reload.order).to eq(2)
      expect(second_todo.reload.order).to eq(3)
      expect(third_todo.reload.order).to eq(1)
    end

    it "renumbers no todos when dragged to the end" do
      first_todo = Todo.create!(title: "First", order: 1)
      second_todo = Todo.create!(title: "Second", order: 2)
      third_todo = Todo.create!(title: "Third", order: 3)

      patch todo_path(first_todo),
            params: { todo: { order: 4 } },
            as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(response.body).to include(%(action="replace" target="todos"))

      expect(first_todo.reload.order).to eq(4)
      expect(second_todo.reload.order).to eq(2)
      expect(third_todo.reload.order).to eq(3)
    end
  end
end

