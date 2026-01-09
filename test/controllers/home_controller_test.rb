require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get accueil" do
    get home_accueil_url
    assert_response :success
  end

  test "should get actualite" do
    get home_actualite_url
    assert_response :success
  end
end
