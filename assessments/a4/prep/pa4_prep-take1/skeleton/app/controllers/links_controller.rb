class LinksController < ApplicationController

  before_action :ensure_logged_in
  before_action :ensure_author, only: [:edit, :update]

  def new
    @link = Link.new
  end

  def create
    @link = Link.new(link_params)
    @link.user_id = current_user.id

    if @link.save
      redirect_to link_url(@link)
    else
      flash.now[:errors] = @link.errors.full_messages
      render :new
    end
  end

  def edit
    @link = Link.find(params[:id])

  end

  def update
    @link = current_user.links.find(params[:id])

    if @link.update(link_params)
      redirect_to link_url(@link)
    else
      flash.now[:errors] = @link.errors.full_messages
      render :edit
    end
  end

  def show
    @link = Link.find(params[:id])
  end

  def index
    @links = Link.all
  end

  def destroy
    link = Link.find(params[:id])
    link.destroy
    redirect_to links_url
  end

  private

    def link_params
      params.require(:link).permit(:title, :url)
    end
end