require "test_helper"

class DietsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get diets_index_url
    assert_response :success
  end

  test "should get show" do
    get diets_show_url
    assert_response :success
  end

  test "should get new" do
    get diets_new_url
    assert_response :success
  end

  test "should get create" do
    get diets_create_url
    assert_response :success
  end

  test "should get edit" do
    get diets_edit_url
    assert_response :success
  end

  test "should get update" do
    get diets_update_url
    assert_response :success
  end

  test "should get destroy" do
    get diets_destroy_url
    assert_response :success
  end
end
