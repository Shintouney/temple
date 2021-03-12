class Admin::ArticlesController < ApplicationController
  include AdminController

  before_action :load_article, only: [:edit, :update, :destroy]
  before_action :build_article, only: [:new, :create]

  def index
    @records_count = Article.count
    @pagy, @records = pagy(Article.all.order('visible DESC, name ASC'), items: 100)
    @records = ArticleDecorator.decorate_collection(@records)
  end

  def new
  end

  def create
    if @article.save
      redirect_to admin_articles_path, notice: t_action_flash(:notice)
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to admin_articles_path, notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render action: 'edit'
    end
  end

  def destroy
    @article.update_attribute :visible, false
    redirect_to admin_articles_path, notice: t_action_flash(:notice)
  end

  private

  def load_article
    @article = Article.find(params[:id])
  end

  def build_article
    @article = Article.new(article_params)
  end

  def article_params
    if params.key?(:article)
      params.require(:article).permit(:name,
                                      :price_ati,
                                      :price_te,
                                      :taxes_rate,
                                      :description,
                                      :article_category_id,
                                      :image,
                                      :visible)
    else
      {}
    end
  end
end
