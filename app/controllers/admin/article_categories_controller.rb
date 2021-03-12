class Admin::ArticleCategoriesController < ApplicationController
  include AdminController

  before_action :load_article_category, only: [:edit, :update, :destroy]
  before_action :build_article_category, only: [:new, :create]

  def index
    @article_categories = ArticleCategory.includes(:articles)
  end

  def new
  end

  def create
    if @article_category.save
      redirect_to admin_article_categories_path, notice: t_action_flash(:notice)
    else
      render action: :new
    end
  end

  def edit
  end

  def update
    if @article_category.update(article_category_params)
      redirect_to admin_article_categories_path, notice: t_action_flash(:notice)
    else
      flash.now[:alert] = t_action_flash(:alert)
      render action: 'edit'
    end
  end

  def destroy
    @article_category.destroy

    redirect_to admin_article_categories_path, notice: t_action_flash(:notice)
  end

  private

  def load_article_category
    @article_category = ArticleCategory.find(params[:id])
  end

  def build_article_category
    @article_category = ArticleCategory.new(article_category_params)
  end

  def article_category_params
    params.key?(:article_category) ? params.require(:article_category).permit(:name) : {}
  end
end
