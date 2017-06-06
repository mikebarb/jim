require 'test_helper'

class OrderlogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @orderlog = orderlogs(:one)
  end

  test "should get index" do
    get orderlogs_url
    assert_response :success
  end

  test "should get new" do
    get new_orderlog_url
    assert_response :success
  end

  test "should create orderlog" do
    assert_difference('Orderlog.count') do
      post orderlogs_url, params: { orderlog: { day: @orderlog.day, product: @orderlog.product, shop: @orderlog.shop, user: @orderlog.user } }
    end

    assert_redirected_to orderlog_url(Orderlog.last)
  end

  test "should show orderlog" do
    get orderlog_url(@orderlog)
    assert_response :success
  end

  test "should get edit" do
    get edit_orderlog_url(@orderlog)
    assert_response :success
  end

  test "should update orderlog" do
    patch orderlog_url(@orderlog), params: { orderlog: { day: @orderlog.day, product: @orderlog.product, shop: @orderlog.shop, user: @orderlog.user } }
    assert_redirected_to orderlog_url(@orderlog)
  end

  test "should destroy orderlog" do
    assert_difference('Orderlog.count', -1) do
      delete orderlog_url(@orderlog)
    end

    assert_redirected_to orderlogs_url
  end
end
