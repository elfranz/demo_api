module Api
  class CustomersController < ApplicationController
    # TODO: add pagination to improve performance
    def index
      customers = Customer.all
      render status: :ok, json: customers
    end

    def show
      customer = Customer.find(params[:id])
      render status: :ok, json: customer
    end

    def create
      customer = Customer.new(create_params)
      return invalid_record_error(customer) unless
        customer.save

      render status: :created, json: customer
    end

    def update
      customer = Customer.find(params[:id])
      customer.assign_attributes(update_params)
      return invalid_record_error(customer) unless
        customer.save

      # TODO: Messages should be internationalized with I18n,
      # we are running out of time though
      render status: :ok, json: { message: 'Data was successfully updated.' }
    end

    def destroy
      customer = Customer.find(params[:id])
      customer.destroy!
      # TODO: Messages should be internationalized with I18n,
      # we are running out of time though
      render status: :ok, json: { message: 'Customer successfully deleted.' }
    end

    private

    def create_params
      required = %i[email name document_number phone_number address]
      required.each { |required_param| params.require(required_param) }
      params.permit(required)
    end

    def update_params
      params.permit(:email, :name, :document_number, :phone_number, :address)
    end
  end
end
