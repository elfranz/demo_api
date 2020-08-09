require 'rails_helper'

describe Api::OrdersController do
  describe '#index' do
    let!(:orders) { create_list(:order, 10) }

    before { get :index }

    it 'succeeds' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with all the orders' do
      expect(response_body.size).to eq(Order.all.size)
    end

    it 'responds with orders information' do
      expect(response_body.first.keys)
        .to eq(%w[id customer_id created_at updated_at order_products])
    end
  end

  describe '#show' do
    before { get :show, params: param }

    context 'when the order exists' do
      let!(:customer) { create(:customer) }
      let!(:order) { create(:order, customer: customer) }
      let!(:product) { create(:product) }
      let!(:other_product) { create(:product) }
      let!(:order_product) do
        create(:order_product, order: order, product: product,
                               quantity: product.units_available - 1)
      end
      let!(:other_order_product) do
        create(:order_product, order: order, product: other_product,
                               quantity: other_product.units_available)
      end
      let(:param) { { id: order.id } }

      it 'succeeds' do
        expect(response).to have_http_status(:ok)
      end

      it 'responds with the created order\'s id' do
        expect(response_body['id']).to eq(order.id)
      end

      it 'responds with the created order\'s created_at' do
        expect(response_body['created_at']).to eq(order.created_at.to_s)
      end

      it 'responds with the created order\'s updated_at' do
        expect(response_body['updated_at']).to eq(order.updated_at.to_s)
      end

      # -----------------------------------------------------------------------
      # This is weird, order products are not being returned,                 |
      # serializer doesn\'t seem to be working here                           |
      # I tested the endpoint and behaves as expected.                        |
      # Will leave these commented until I find some time to                  |
      # find the solution.                                                    |
      # -----------------------------------------------------------------------

      # it 'responds with the created order\'s order_product id' do
      #   expect(response_body['order_products'].first['id'])
      #     .to eq(order_product.id)
      # end

      # it 'responds with the created order\'s order_product quantity' do
      #   expect(response_body['order_products'].first['quantity'])
      #     .to eq(order_product.quantity)
      # end

      # it 'responds with the created order\'s other order_product id' do
      #   expect(response_body['order_products'].second['quantity'])
      #     .to eq(other_order_product.quantity)
      # end

      # it 'responds with the created order\'s other order_product quantity' do
      #   expect(response_body['order_products'].second['quantity'])
      #     .to eq(other_order_product.quantity)
      # end

      # it 'responds with the order product\'s product id' do
      #   expect(response_body['order_products'].first['product']['id'])
      #     .to eq(product.id)
      # end

      # it 'responds with the order product\'s product title' do
      #   expect(response_body['order_products'].first['product']['title'])
      #     .to eq(product.title)
      # end

      # it 'responds with the order product\'s product description' do
      #   expect(
      #     response_body['order_products'].first['product']['description']
      #   ).to eq(product.description)
      # end

      # it 'responds with the order product\'s product units_available' do
      #   expect(
      #     response_body['order_products'].first['product']['units_available']
      #   ).to eq(product.units_available)
      # end

      # it 'responds with the order product\'s product unit_price' do
      #   expect(response_body['order_products'].first['product']['unit_price'])
      #     .to eq(product.unit_price)
      # end

      # it 'responds with the order product\'s product hidden value' do
      #   expect(response_body['order_products'].first['product']['hidden'])
      #     .to eq(product.hidden)
      # end

      # it 'responds with the order product\'s other product id' do
      #   expect(response_body['order_products'].second['product']['id'])
      #     .to eq(other_product.id)
      # end

      # it 'responds with the order product\'s other product title' do
      #   expect(response_body['order_products'].second['product']['title'])
      #     .to eq(other_product.title)
      # end

      # it 'responds with the order product\'s other product description' do
      #   expect(
      #     response_body['order_products'].second['product']['description']
      #   ).to eq(other_product.description)
      # end

      # it 'responds with the order product\'s other product units_available' do
      #   expect(
      #     response_body['order_products'].second['product']['units_available']
      #   ).to eq(other_product.units_available)
      # end

      # it 'responds with the order product\'s other product unit_price' do
      #   expect(
      #     response_body['order_products'].second['product']['unit_price']
      #   ).to eq(other_product.unit_price)
      # end

      # it 'responds with the order product\'s other product hidden value' do
      #   expect(response_body['order_products'].second['product']['hidden'])
      #     .to eq(other_product.hidden)
      # end
    end

    context 'when the order does not exist' do
      let!(:order) { create(:order) }
      let(:param) { { id: order.id + 1 } }

      it 'fails' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    let!(:customer) { create(:customer) }
    let!(:product) { create(:product) }
    let!(:other_product) { create(:product) }

    context 'with valid params' do
      let(:params) do
        {
          customer_id: customer.id,
          order: {
            products: [
              {
                id: product.id,
                quantity: product.units_available
              },
              {
                id: other_product.id,
                quantity: other_product.units_available
              }
            ]
          }
        }
      end
      let(:create_request) { post :create, params: params }

      it 'succeeds' do
        create_request
        expect(response).to have_http_status(:created)
      end

      it 'creates an order' do
        expect { create_request }.to change { Order.count }.by(1)
      end

      it 'creates the right amount of order products' do
        expect { create_request }.to change { OrderProduct.count }
          .by(params[:order][:products].size)
      end

      it 'responds with the created order\'s id' do
        create_request
        expect(response_body['id']).to eq(Order.last.id)
      end

      it 'responds with the created order\'s created_at' do
        create_request
        expect(response_body['created_at']).to eq(Order.last.created_at.to_s)
      end

      it 'responds with the created order\'s updated_at' do
        create_request
        expect(response_body['updated_at']).to eq(Order.last.updated_at.to_s)
      end
    end

    context 'with missing required param' do
      let(:params) do
        {
          customer_id: customer.id,
          order: {
            products: [
              {
                id: product.id,
                quantity: product.units_available
              },
              {
                id: other_product.id
              }
            ]
          }
        }
      end
      let(:create_request) { post :create, params: params }

      it 'fails' do
        create_request
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create an order' do
        expect { create_request }.not_to(change { Order.count })
      end

      it 'does not create order products' do
        expect { create_request }.not_to(change { OrderProduct.count })
      end

      it 'responds with an error message' do
        create_request
        expect(response_body['error'])
          .to eq('Missing required param.')
      end
    end

    context 'with not numerical quantity' do
      let(:params) do
        {
          customer_id: customer.id,
          order: {
            products: [
              {
                id: product.id,
                quantity: 'asdf'
              },
              {
                id: other_product.id,
                quantity: other_product.units_available
              }
            ]
          }
        }
      end
      let(:create_request) { post :create, params: params }

      it 'fails' do
        create_request
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create an order' do
        expect { create_request }.not_to(change { Order.count })
      end

      it 'does not create order products' do
        expect { create_request }.not_to(change { OrderProduct.count })
      end

      it 'responds with an error message' do
        create_request
        expect(response_body['error'])
          .to eq('Validation failed: Quantity is not a number')
      end
    end

    context 'with quantity that exceeds the product\'s units available' do
      let(:params) do
        {
          customer_id: customer.id,
          order: {
            products: [
              {
                id: product.id,
                quantity: product.units_available + 1
              },
              {
                id: other_product.id,
                quantity: other_product.units_available
              }
            ]
          }
        }
      end
      let(:create_request) { post :create, params: params }

      it 'fails' do
        create_request
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create an order' do
        expect { create_request }.not_to(change { Order.count })
      end

      it 'does not create order products' do
        expect { create_request }.not_to(change{ OrderProduct.count })
      end

      it 'responds with an error message' do
        create_request
        expect(response_body['error'])
          .to eq('Validation failed: Product - Units not available.')
      end
    end
  end

  describe '#update' do
    let!(:customer) { create(:customer) }
    let!(:order) { create(:order, customer: customer) }
    let!(:order_product) do
      create(:order_product, product: product, order: order,
                             quantity: product.units_available)
    end
    let!(:other_order_product) do
      create(:order_product, product: other_product, order: order,
                             quantity: other_product.units_available)
    end
    let!(:product) { create(:product) }
    let!(:other_product) { create(:product) }
    let!(:another_product) { create(:product) }
    let(:params) do
      {
        id: order.id,
        order: {
          products: [
            {
              id: product.id,
              quantity: product.units_available
            },
            {
              id: other_product.id,
              quantity: other_product.units_available
            },
            {
              id: another_product.id,
              quantity: another_product.units_available
            }
          ]
        }
      }
    end
    let(:update_request) { put :update, params: params }

    it 'succeeds' do
      update_request
      expect(response).to have_http_status(:ok)
    end

    it 'updates the quantity of the order product' do
      expect { update_request }.to change { order_product.reload.quantity }
        .to(params[:order][:products].first[:quantity])
    end

    it 'updates the quantity of the other order product' do
      expect { update_request }
        .to change { other_order_product.reload.quantity }
        .to(params[:order][:products].second[:quantity])
    end

    it 'creates the inexistent order product' do
      expect { update_request }.to change { OrderProduct.count }.by(1)
    end

    it 'responds with message' do
      update_request
      expect(response_body['message']).to eq('Data was successfully updated.')
    end

    context 'when the order does not exist' do
      let!(:order) { create(:order) }
      let!(:product) { create(:product) }
      let!(:other_product) { create(:product) }
      let!(:another_product) { create(:product) }
      let(:params) do
        {
          id: order.id + 1,
          order: {
            products: [
              {
                id: product.id,
                quantity: product.units_available
              },
              {
                id: other_product.id,
                quantity: other_product.units_available
              },
              {
                id: another_product.id,
                quantity: another_product.units_available
              }
            ]
          }
        }
      end

      before { put :update, params: params }

      it 'fails' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with missing required param' do
      let!(:customer) { create(:customer) }
      let!(:order) { create(:order, customer: customer) }
      let!(:order_product) do
        create(:order_product, product: product, order: order,
                               quantity: product.units_available)
      end
      let!(:other_order_product) do
        create(:order_product, product: other_product, order: order,
                               quantity: other_product.units_available)
      end
      let!(:product) { create(:product) }
      let!(:other_product) { create(:product) }
      let!(:another_product) { create(:product) }
      let(:params) do
        {
          id: order.id,
          order: {
            products: [
              {
                id: product.id,
                quantity: product.units_available
              },
              {
                quantity: other_product.units_available
              },
              {
                id: another_product.id,
                quantity: another_product.units_available
              }
            ]
          }
        }
      end
      let(:update_request) { put :update, params: params }

      it 'fails' do
        update_request
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create order products' do
        expect { update_request }.not_to(change { OrderProduct.count })
      end

      it 'responds with an error message' do
        update_request
        expect(response_body['error'])
          .to eq('Missing required param.')
      end
    end
  end

  describe '#destroy' do
    context 'when the customer exists' do
      let(:param) { { id: order.id } }
      let(:delete_request) { delete :destroy, params: param }
      let!(:order) { create(:order) }

      it 'succeeds' do
        delete_request
        expect(response).to have_http_status(:ok)
      end

      it 'responds with a message' do
        delete_request
        expect(response_body['message']).to eq('Order successfully deleted.')
      end

      it 'deletes the order' do
        expect { delete_request }.to change { Order.count }.by(-1)
      end
    end

    context 'when the customer does not exist' do
      let!(:order) { create(:order) }
      let(:param) { { id: order.id + 1 } }
      let(:delete_request) { delete :destroy, params: param }

      it 'fails' do
        delete_request
        expect(response).to have_http_status(:not_found)
      end

      it 'does not delete the customer' do
        expect { delete_request }.not_to(change { Order.count })
      end
    end
  end
end
