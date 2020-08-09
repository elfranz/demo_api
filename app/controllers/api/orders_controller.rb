module Api
  class OrdersController < ApplicationController
    # TODO: add pagination to improve performance
    def index
      orders = Order.all
      render status: :ok, json: orders
    end

    def show
      order = Order.find(params[:id])
      render status: :ok,
             json: order
    end

    def create
      create_order(require_create_params)
      render status: :created, json: @order
    end

    def update
      update_order(require_update_params)
      render status: :ok, json: { message: 'Data was successfully updated.' }
    end

    def destroy
      order = Order.find(params[:id])
      order.destroy!
      # TODO: Messages should be internationalized with I18n,
      # we are running out of time though
      render status: :ok, json: { message: 'Order successfully deleted.' }
    end

    private

    def require_create_params
      permitted = require_nested(
        {
          customer_id: true, order: {
            products: [{ id: true, quantity: true }]
          }
        },
        params
      )
      params.permit(permitted)
    end

    def create_order(create_params)
      ActiveRecord::Base.transaction do
        @order = Order.create!(customer_id: create_params[:customer_id])
        create_params[:order][:products].each do |product|
          OrderProduct.create!(
            order: @order, product_id: product[:id], quantity: product[:quantity]
          )
        end
      end
    end

    def require_update_params
      permitted = require_nested(
        {
          id: true,
          order: {
            products: [{ id: true, quantity: true }]
          }
        },
        params
      )
      params.permit(permitted)
    end

    def update_order(update_params)
      Order.find(update_params[:id])
      ActiveRecord::Base.transaction do
        update_params[:order][:products].each do |product|
          next @order_product.update!(quantity: product[:quantity]) if
            order_product_exists?(update_params[:id], product[:id])

          OrderProduct.create!(
            order_id: update_params[:id], product_id: product[:id],
            quantity: product[:quantity]
          )
        end
      end
    end

    def order_product_exists?(order_id, product_id)
      @order_product = OrderProduct.find_by(
        order_id: order_id, product_id: product_id
      )
      @order_product.present?
    end
  end
end
