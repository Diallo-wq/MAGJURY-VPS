require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get completion_enchere_profile" do
    get profiles_completion_enchere_profile_url
    assert_response :success
  end

  test "should get save_enchere_profile" do
    get profiles_save_enchere_profile_url
    assert_response :success
  end
end
