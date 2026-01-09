class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_redacteur!
  layout 'dashboard'
  def index
     @total_user = User.all
     @total_post =Post.published.count
     @total_product = Product.count
     @total_enchere = Auction.count
     @total_service = Service.count
     @total_job_offers = JobOffer.count
  end
end
