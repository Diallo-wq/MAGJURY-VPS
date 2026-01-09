require "application_system_test_case"

class AuctionsTest < ApplicationSystemTestCase
  setup do
    @auction = auctions(:one)
  end

  test "visiting the index" do
    visit auctions_url
    assert_selector "h1", text: "Auctions"
  end

  test "should create auction" do
    visit auctions_url
    click_on "New auction"

    fill_in "Debut", with: @auction.debut
    fill_in "Description", with: @auction.description
    fill_in "Fin", with: @auction.fin
    fill_in "Localisation", with: @auction.localisation
    fill_in "Nombre mises", with: @auction.nombre_mises
    fill_in "Prix actuel", with: @auction.prix_actuel
    fill_in "Prix depart", with: @auction.prix_depart
    fill_in "Statut", with: @auction.statut
    fill_in "Titre", with: @auction.titre
    fill_in "User", with: @auction.user_id
    click_on "Create Auction"

    assert_text "Auction was successfully created"
    click_on "Back"
  end

  test "should update Auction" do
    visit auction_url(@auction)
    click_on "Edit this auction", match: :first

    fill_in "Debut", with: @auction.debut
    fill_in "Description", with: @auction.description
    fill_in "Fin", with: @auction.fin
    fill_in "Localisation", with: @auction.localisation
    fill_in "Nombre mises", with: @auction.nombre_mises
    fill_in "Prix actuel", with: @auction.prix_actuel
    fill_in "Prix depart", with: @auction.prix_depart
    fill_in "Statut", with: @auction.statut
    fill_in "Titre", with: @auction.titre
    fill_in "User", with: @auction.user_id
    click_on "Update Auction"

    assert_text "Auction was successfully updated"
    click_on "Back"
  end

  test "should destroy Auction" do
    visit auction_url(@auction)
    click_on "Destroy this auction", match: :first

    assert_text "Auction was successfully destroyed"
  end
end
