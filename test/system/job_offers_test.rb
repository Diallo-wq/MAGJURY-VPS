require "application_system_test_case"

class JobOffersTest < ApplicationSystemTestCase
  setup do
    @job_offer = job_offers(:one)
  end

  test "visiting the index" do
    visit job_offers_url
    assert_selector "h1", text: "Job offers"
  end

  test "should create job offer" do
    visit job_offers_url
    click_on "New job offer"

    fill_in "Active", with: @job_offer.active
    fill_in "Company", with: @job_offer.company
    fill_in "Contact phone", with: @job_offer.contact_phone
    fill_in "Contract type", with: @job_offer.contract_type
    fill_in "Description", with: @job_offer.description
    fill_in "Location", with: @job_offer.location
    check "Remote" if @job_offer.remote
    fill_in "Salary", with: @job_offer.salary
    fill_in "Title", with: @job_offer.title
    click_on "Create Job offer"

    assert_text "Job offer was successfully created"
    click_on "Back"
  end

  test "should update Job offer" do
    visit job_offer_url(@job_offer)
    click_on "Edit this job offer", match: :first

    fill_in "Active", with: @job_offer.active
    fill_in "Company", with: @job_offer.company
    fill_in "Contact phone", with: @job_offer.contact_phone
    fill_in "Contract type", with: @job_offer.contract_type
    fill_in "Description", with: @job_offer.description
    fill_in "Location", with: @job_offer.location
    check "Remote" if @job_offer.remote
    fill_in "Salary", with: @job_offer.salary
    fill_in "Title", with: @job_offer.title
    click_on "Update Job offer"

    assert_text "Job offer was successfully updated"
    click_on "Back"
  end

  test "should destroy Job offer" do
    visit job_offer_url(@job_offer)
    click_on "Destroy this job offer", match: :first

    assert_text "Job offer was successfully destroyed"
  end
end
