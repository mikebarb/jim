require 'test_helper'

class UsershopsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @usershop = usershops(:one)
  end

  test "should get index" do
    get usershops_url
    assert_response :success
  end

  test "should get new" do
    get new_usershop_url
    assert_response :success
  end

  test "should create usershop" do
    assert_difference('Usershop.count') do
      post usershops_url, params: { usershop: { shop_id: @usershop.shop_id, user_id: @usershop.user_id } }
    end

    assert_redirected_to usershop_url(Usershop.last)
  end

  test "should show usershop" do
    get usershop_url(@usershop)
    assert_response :success
  end

  test "should get edit" do
    get edit_usershop_url(@usershop)
    assert_response :success
  end

  test "should update usershop" do
    patch usershop_url(@usershop), params: { usershop: { shop_id: @usershop.shop_id, user_id: @usershop.user_id } }
    assert_redirected_to usershop_url(@usershop)
  end

  test "should destroy usershop" do
    assert_difference('Usershop.count', -1) do
      delete usershop_url(@usershop)
    end

    assert_redirected_to usershops_url
  end
end
