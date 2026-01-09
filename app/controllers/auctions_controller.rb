class AuctionsController < ApplicationController
  before_action :set_auction, only: %i[ show edit update destroy ]
  layout 'dashboard', except: [:show]
  before_action :authenticate_user!, except: %i[mes_encheres show]
  before_action :require_admin!, except: [:mes_encheres, :show]
  # GET /auctions or /auctions.json
 
  def index
     @auctions = Auction.all.includes(:user, :bids)
                       .order(created_at: :desc)
    filter_collection if params[:commit].present?
  end

   def mes_encheres
    @encheres = Auction
                  .joins(:bids)                       # uniquement si une mise existe
                  .where(bids: { user_id: current_user.id })
                  .distinct                           # pas de doublons
                  .includes(:bids)                    # N+1
                  .order(created_at: :desc)
    filter_collection if params[:commit].present?
  end

   def show
    @auction = Auction.find(params[:id])
    # CLASSEMENT : du PLUS haut au PLUS bas
    @bids = @auction.bids.order(montant: :desc)
    @new_bid = Bid.new
  end

  # GET /auctions/new
  def new
    @auction = Auction.new
  end

  # GET /auctions/1/edit
  def edit
  end

  # POST /auctions or /auctions.json
  def create
    @auction = Auction.new(auction_params)
    @auction.user = current_user

    respond_to do |format|
      if @auction.save
        format.html { redirect_to @auction, notice: "Auction was successfully created." }
        format.json { render :show, status: :created, location: @auction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /auctions/1 or /auctions/1.json
  def update
    respond_to do |format|
      if @auction.update(auction_params)
        format.html { redirect_to @auction, notice: "Auction was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @auction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auctions/1 or /auctions/1.json
  def destroy
    @auction.destroy

    respond_to do |format|
      format.html { redirect_to auctions_path, notice: "Auction was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def publish
    @auction = Auction.find(params[:id])
    @auction.bientot! if @auction.brouillon?
    redirect_to @auction, notice: "Vente programmée et visible."
  end

 def start
    @auction = Auction.publiques.find(params[:id])
    @auction.en_cours! if @auction.may_start?
    head :ok
  end

  def close
    @auction = Auction.publiques.find(params[:id])
    @auction.terminee!  if @auction.may_close?
    head :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_auction
      @auction = Auction.find(params[:id])
    end


    def filter_collection
      @auctions = @auctions.where(statut: params[:statut]) if params[:statut].present?
      @auctions = @auctions.where("titre ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @auctions = @auctions.where(localisation: params[:loc]) if params[:loc].present?
    end

    def set_status(status, message)
      @auction = Auction.find(params[:id])
      @auction.update!(statut: status)
      redirect_to admin_auctions_path, notice: "Vente #{message}."
    end

    # Only allow a list of trusted parameters through.
    def auction_params
      params.require(:auction).permit(:titre, :description, :prix_depart, :prix_actuel, :nombre_mises, :statut, :debut, :fin, :localisation, :user_id, :image)
    end
end
