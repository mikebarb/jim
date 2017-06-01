require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get baker" do
    get reports_baker_url
    assert_response :success
  end

  test "should get deliver" do
    get reports_deliver_url
    assert_response :success
  end

end
