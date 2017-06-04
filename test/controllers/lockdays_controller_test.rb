require 'test_helper'

class LockdaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lockday = lockdays(:one)
  end

  test "should get index" do
    get lockdays_url
    assert_response :success
  end

  test "should get new" do
    get new_lockday_url
    assert_response :success
  end

  test "should create lockday" do
    assert_difference('Lockday.count') do
      post lockdays_url, params: { lockday: { day: @lockday.day, locked: @lockday.locked, user_id: @lockday.user_id } }
    end

    assert_redirected_to lockday_url(Lockday.last)
  end

  test "should show lockday" do
    get lockday_url(@lockday)
    assert_response :success
  end

  test "should get edit" do
    get edit_lockday_url(@lockday)
    assert_response :success
  end

  test "should update lockday" do
    patch lockday_url(@lockday), params: { lockday: { day: @lockday.day, locked: @lockday.locked, user_id: @lockday.user_id } }
    assert_redirected_to lockday_url(@lockday)
  end

  test "should destroy lockday" do
    assert_difference('Lockday.count', -1) do
      delete lockday_url(@lockday)
    end

    assert_redirected_to lockdays_url
  end
end
