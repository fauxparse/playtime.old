require 'test_helper'

class ShowsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get availability" do
    get :availability
    assert_response :success
  end

end
