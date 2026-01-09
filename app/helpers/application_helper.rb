module ApplicationHelper
  include CloudinaryHelper
  # app/helpers/application_helper.rb
  def can_edit_post?(post)
    user_signed_in? && (current_user.admin? || current_user.redacteur? || post.user == current_user)
  end
  # app/helpers/application_helper.rb
def site_name
  SiteSetting.current.site_name
end

def site_description
  SiteSetting.current.description
end

def site_localisation
  SiteSetting.current.localisation
end


def currency_symbol
  SiteSetting.current.currency_symbol.presence  || '€'
end

def devise
  SiteSetting.current.currency 
end

def site_time_zone
  SiteSetting.current.time_zone
end

def site_tel1
  SiteSetting.current.tel1
end

def site_whatsapp
  SiteSetting.current.whatsapp
end

def site_email
  SiteSetting.current.site_email.presence || "contact@magjury.com"
end

def site_social(network)
  SiteSetting.current.send(network) # :facebook, :linkedin, etc.
end
end