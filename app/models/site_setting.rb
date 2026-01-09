# app/models/site_setting.rb
class SiteSetting < ApplicationRecord

    has_one_attached :logo
  # devises : symboles ISO
  CURRENCIES = {
    "EUR" => "€",
    "USD" => "$",
    "FCFA" => "FCFA",
    "GBP" => "£",
    "JPY" => "¥"
  }

  # fuseaux horaires communs
  TIME_ZONES = [
    "UTC",
    "UTC+1", "UTC+2", "UTC+3",
    "UTC-1", "UTC-2", "UTC-3",
    "Africa/Douala", "Africa/Abidjan", "Europe/Paris"
  ]

  # singleton
  def self.current
    first_or_create!(
      site_name: "MagJury",
      currency: "EUR",
      time_zone: "UTC+1",
      devise: "€"
    )
  end

  def currency_symbol
    CURRENCIES[currency] || "€"
  end
end