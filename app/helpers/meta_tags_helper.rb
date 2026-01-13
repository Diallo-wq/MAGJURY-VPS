# app/helpers/meta_tags_helper.rb
module MetaTagsHelper
  def meta_title
    content_for?(:meta_title) ? content_for(:meta_title) : "MAGJURY - Plateforme juridique et magazine"
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : "MAGJURY est la première plateforme juridique alliant services professionnels et magazine d'actualités juridiques en Guinée."
  end

  def meta_image
    if content_for?(:meta_image)
      content_for(:meta_image)
    else
      # URL du logo par défaut (à adapter selon ton logo)
      "#{request.base_url}/assets/logo.png"
    end
  end

  def meta_url
    content_for?(:meta_url) ? content_for(:meta_url) : request.original_url
  end

  def meta_type
    content_for?(:meta_type) ? content_for(:meta_type) : "website"
  end

  def meta_keywords
    content_for?(:meta_keywords) ? content_for(:meta_keywords) : "Droit, Justice, Avocat, Guinée, Actualités juridiques"
  end

  def meta_author
    content_for?(:meta_author) ? content_for(:meta_author) : "MAGJURY"
  end
end
