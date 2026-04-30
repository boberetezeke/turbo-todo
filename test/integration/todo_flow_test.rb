require "test_helper"

class TodoFlowTest < ActionDispatch::IntegrationTest
  test "creating a todo without turbo redirects back to the index" do
    assert_difference("Todo.count", 1) do
      post todo_index_path, params: { todo: { title: "Walk the dog" } }
    end

    assert_redirected_to root_path

    follow_redirect!
    assert_response :success
    assert_includes response.body, "Walk the dog"
  end

  test "creating a todo with turbo streams appends it to the list and resets the form" do
    assert_difference("Todo.count", 1) do
      post todo_index_path,
        params: { todo: { title: "Buy milk" } },
        as: :turbo_stream
    end

    assert_response :created
    assert_equal Mime[:turbo_stream], response.media_type
    assert_includes response.body, %(action="append" target="todos")
    assert_includes response.body, %(action="replace" target="new_todo")
    assert_includes response.body, "Buy milk"
  end

  test "blank turbo stream submissions replace the form with errors" do
    assert_no_difference("Todo.count") do
      post todo_index_path,
        params: { todo: { title: "" } },
        as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_equal Mime[:turbo_stream], response.media_type
    assert_includes response.body, %(action="replace" target="new_todo")
    assert_match(/Title can(?:&#39;|')t be blank/, response.body)
  end
end
