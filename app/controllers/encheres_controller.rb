# app/controllers/encheres_controller.rb
class EncheresController < ApplicationController
  before_action :set_filters, only: :index

  def index
    @encheres = Auction.publiques
                       .order(fin: :asc)
                       .includes(:bids) # N+1
    filter_by_status if params[:status].present?
    filter_by_price  if params[:prix_max].present?
    filter_by_loc    if params[:loc].present?
  end

  private

  def set_filters
    @statuses = Auction.publiques.pluck(:statut).uniq.sort
    @locs     = Auction.publiques.pluck(:localisation).uniq.sort
  end

  def filter_by_status; @encheres = @encheres.where(statut: params[:status]); end
  def filter_by_price;  @encheres = @encheres.where("prix_actuel <= ?", params[:prix_max]); end
  def filter_by_loc;    @encheres = @encheres.where(localisation: params[:loc]); end
end