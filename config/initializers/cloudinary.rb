Cloudinary.config do |config|
  config.cache_storage = :file
  config.fog_provider = 'fog/cloudinary'
  config.fog_credentials = {
    provider: "Cloudinary",
    cloud_name: "dwe47it6l",
    api_key: "585337992323854",
    api_secret: "hlPOFfZ4BX-Y0_ACDp5B3r3ptMg"
  }

end
