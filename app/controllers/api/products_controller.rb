module Api
  class ProductsController < ApplicationController
    # TODO: add pagination to improve performance
    def index
      products = Product.all
      render status: :ok, json: products
    end

    def show
      product = Product.find(params[:id])
      render status: :ok, json: product
    end

    def create
      product = Product.new(create_params)
      return invalid_record_error(product) unless
        product.save

      render status: :created, json: product
    end

    def update
      product = Product.find(params[:id])
      product.assign_attributes(product_params)
      return invalid_record_error(product) unless
        product.save

      # TODO: Messages should be internationalized with I18n,
      # we are running out of time though
      render status: :ok, json: { message: 'Data was successfully updated.' }
    end

    def destroy
      product = Product.find(params[:id])
      product.destroy!
      # TODO: Messages should be internationalized with I18n,
      # we are running out of time though
      render status: :ok, json: { message: 'Product successfully deleted.' }
    end

    private

    def create_params
      required = %i[title description unit_price]
      required.each { |required_param| params.require(required_param) }
      product_params
    end

    def product_params
      params.permit(
        :title, :description, :units_available, :unit_price, :hidden
      )
    end
  end
end
