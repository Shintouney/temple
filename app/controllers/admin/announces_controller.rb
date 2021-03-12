class Admin::AnnouncesController < ApplicationController
  include AdminController

  before_action :load_announce, only: [:edit, :update, :destroy]

  def index
    @announces = AnnounceDecorator.decorate_collection(Announce.all.order("start_at DESC, end_at DESC, created_at DESC"))
    @current_announces = AnnounceDecorator.decorate_collection(Announce.current.active.for_all)
  end

  def new
    @announce = Announce.new
  end

  def edit
  end

  def create
    @announce = Announce.new(announce_params)

    if @announce.save
      redirect_to edit_admin_announce_path(@announce), notice: t('.notice')
    else
      render action: 'new'
    end
  end

  def update
    if @announce.update(announce_params)
      redirect_to edit_admin_announce_path(@announce), notice: t('.notice')
    else
      render action: 'edit'
    end
  end

  def destroy
    @announce.destroy
    redirect_to admin_announces_url, notice: t('.notice')
  end

  private

    def load_announce
      @announce = AnnounceDecorator.decorate(Announce.find(params[:id]))
    end

    def announce_params
      params.require(:announce).permit(:content, :group_id, :start_at, :end_at, :file, :target_link, :external_link, :active, :place)
    end
end
