class Admin::OrdersController < ApplicationController
  include AdminController

  before_action :load_user
  before_action :load_order, only: [:show, :destroy]
  before_action :build_order, only: [:new, :create]

  def index
    @pagy, @user_orders = pagy(@user.user.orders)
    @user_orders = OrderDecorator.decorate_collection(@user_orders)
  end

  def show
  end

  def destroy
    if @order.destroy
      flash[:notice] = t_action_flash(:notice)
    else
      flash[:alert] = t_action_flash(:alert)
    end

    redirect_to admin_user_orders_path(@user)
  end

  def new
  end

  def create
    if product_ids_params.empty?
      flash.now[:alert] = t_action_flash(:alert_empty)
      render :new
    else
      if direct_payment_param
        create_order = Invoice::Direct::CreateAndCharge.new(@user, product_ids_params, location_param)
      else
        deferred_invoice = @user.reload.current_deferred_invoice
        if !deferred_invoice.present? && @user.current_subscription.present?
          Invoice::Deferred::Create.new(@user).execute 
          deferred_invoice = @user.reload.current_deferred_invoice
        end
        unless deferred_invoice.present?
          flash.now[:alert] = t_action_flash(:alert_deferred_invoice_missing)
          render :new
          return
        end
        create_order = Invoice::AddArticles.new(deferred_invoice, product_ids_params, location_param)
      end

      if create_order.execute
        redirect_to admin_user_path(@user), notice: t_action_flash(:notice)
      else
        flash.now[:alert] = t_action_flash(:alert_payment_failed)
        render :new
      end
    end
  end

  private

  def load_user
    @user = UserDecorator.decorate(User.find(params[:user_id]))
  end

  def load_order
    @order = OrderDecorator.decorate(@user.object.orders.find(params[:id]))
  end

  def build_order
    @order = Order.new(direct_payment: direct_payment_param, location: location_param)
    @order.order_items.build
  end

  def direct_payment_param
    params.key?(:order) ? (params[:order][:direct_payment] == '1') : false
  end

  def product_ids_params
    params.fetch(:order, {}).
            fetch(:order_items_attributes, {}).
            map { |order_item_attributes| order_item_attributes[:product_id] }.
            reject(&:blank?)
  end

  def location_param
    params[:order].present? ? params[:order][:location] : 'moliere'
  end
end
