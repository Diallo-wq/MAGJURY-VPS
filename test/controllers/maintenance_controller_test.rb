require "test_helper"

class MaintenanceControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get maintenance_index_url
    assert_response :success
  end
end
