require 'rails_helper'

describe Api::ProductsController do
  describe '#index' do
    let!(:products) { create_list(:product, 10) }

    before { get :index }

    it 'succeeds' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with all the products' do
      expect(response_body.size).to eq(Product.all.size)
    end

    it 'responds with products information' do
      expect(response_body.first.keys)
        .to eq(%w[id title description units_available unit_price hidden])
    end
  end

  describe '#show' do
    before { get :show, params: param }

    context 'when the product exists' do
      let!(:product) { create(:product) }
      let(:param) { { id: product.id } }

      it 'succeeds' do
        expect(response).to have_http_status(:ok)
      end

      it 'responds with the created product\'s id' do
        expect(response_body['id']).to eq(product.id)
      end

      it 'responds with the created product\'s email' do
        expect(response_body['title']).to eq(product.title)
      end

      it 'responds with the created product\'s name' do
        expect(response_body['description']).to eq(product.description)
      end

      it 'responds with the created product\'s units available' do
        expect(response_body['units_available'])
          .to eq(product.units_available)
      end

      it 'responds with the created product\'s unit_price' do
        expect(response_body['unit_price'])
          .to eq(product.unit_price.to_s)
      end

      it 'responds with the created product\'s hidden' do
        expect(response_body['hidden']).to eq(product.hidden)
      end
    end

    context 'when the product does not exist' do
      let!(:product) { create(:product) }
      let(:param) { { id: product.id + 1 } }

      it 'fails' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    context 'with valid params' do
      let(:product_params) { attributes_for(:product) }
      let(:create_request) { post :create, params: product_params }

      it 'succeeds' do
        create_request
        expect(response).to have_http_status(:created)
      end

      it 'creates a product' do
        expect { create_request }.to change{ Product.count }.by(1)
      end

      it 'responds with the created product\'s id' do
        create_request
        expect(response_body['id']).to eq(Product.last.id)
      end

      it 'responds with the created product\'s title' do
        create_request
        expect(response_body['title']).to eq(product_params[:title])
      end

      it 'responds with the created product\'s description' do
        create_request
        expect(response_body['description']).to eq(product_params[:description])
      end

      it 'responds with the created product\'s units available' do
        create_request
        expect(response_body['units_available'])
          .to eq(product_params[:units_available])
      end

      it 'responds with the created product\'s unit price' do
        create_request
        expect(response_body['unit_price'])
          .to eq(product_params[:unit_price].to_s)
      end

      it 'responds with the created product\'s hidden value' do
        create_request
        expect(response_body['hidden']).to eq(product_params[:hidden])
      end
    end

    context 'with invalid params' do
      context 'when sending a string to units_available' do
        let(:product_params) do
          {
            title: Faker::Internet.email,
            description: Faker::Name.name_with_middle,
            units_available: 'string',
            unit_price: Faker::Number.number(digits: 11),
            hidden: [true, false].sample
          }
        end
        let(:create_request) { post :create, params: product_params }

        it 'fails' do
          create_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a product' do
          expect { create_request }.not_to(change { Product.count })
        end

        it 'responds with array pointing out the possible errors' do
          create_request
          expect(response_body['error'])
            .to eq(['Units available is not a number.'])
        end
      end

      context 'when sending a string to unit_price' do
        let(:product_params) do
          {
            title: Faker::Internet.email,
            description: Faker::Name.name_with_middle,
            units_available: Faker::Number.number(digits: 3),
            unit_price: 'string',
            hidden: [true, false].sample
          }
        end
        let(:create_request) { post :create, params: product_params }

        it 'fails' do
          create_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a product' do
          expect { create_request }.not_to(change { Product.count })
        end

        it 'responds with array pointing out the possible errors' do
          create_request
          expect(response_body['error'])
            .to eq(['Unit price is not a number.'])
        end
      end
    end

    context 'with missing required param' do
      let(:product_params) { attributes_for(:product) }
      let(:required) { %i[title description unit_price] }
      let(:create_request) do
        post :create, params: product_params.except(required.sample)
      end

      it 'fails' do
        create_request
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a product' do
        expect { create_request }.not_to(change { Product.count })
      end

      it 'responds with an error message' do
        create_request
        expect(response_body['error'])
          .to eq('Missing required param.')
      end
    end
  end

  describe '#update' do
    context 'when the product exists' do
      context 'when sending all the parameters' do
        let!(:product) { create(:product, hidden: false) }
        let(:params) do
          {
            id: product.id,
            title: Faker::Lorem.sentence,
            description: Faker::Lorem.sentence,
            units_available: Faker::Number.number(digits: 3),
            unit_price: Faker::Number.decimal(l_digits: 4, r_digits: 2),
            hidden: true
          }
        end
        let(:update_request) { put :update, params: params }

        it 'succeeds' do
          update_request
          expect(response).to have_http_status(:ok)
        end

        it 'responds with message' do
          update_request
          expect(response_body['message'])
            .to eq('Data was successfully updated.')
        end

        it 'updates the product\'s title' do
          expect { update_request }.to change { product.reload.title }
            .to(params[:title])
        end

        it 'updates the product\'s description' do
          expect { update_request }.to change { product.reload.description }
            .to(params[:description])
        end

        it 'updates the product\'s units available' do
          expect { update_request }
            .to change { product.reload.units_available }
            .to(params[:units_available])
        end

        it 'updates the product\'s unit price' do
          expect { update_request }.to change { product.reload.unit_price }
            .to(params[:unit_price])
        end

        it 'updates the product\'s hidden value' do
          expect { update_request }.to change { product.reload.hidden }
            .to(params[:hidden])
        end
      end

      context 'when sending some parameters' do
        let!(:product) { create(:product) }
        let(:params) do
          {
            id: product.id,
            title: Faker::Lorem.sentence,
            description: Faker::Lorem.sentence
          }
        end
        let(:update_request) { put :update, params: params }

        it 'succeeds' do
          update_request
          expect(response).to have_http_status(:ok)
        end

        it 'responds with message' do
          update_request
          expect(response_body['message'])
            .to eq('Data was successfully updated.')
        end

        it 'updates the product\'s title' do
          expect { update_request }.to change { product.reload.title }
            .to(params[:title])
        end

        it 'updates the product\'s description' do
          expect { update_request }.to change { product.reload.description }
            .to(params[:description])
        end

        it 'does not update the product\'s unit_price' do
          expect { update_request }.not_to(
            change { product.reload.unit_price }
          )
        end

        it 'does not update the product\'s hidden value' do
          expect { update_request }.not_to(
            change { product.reload.hidden }
          )
        end

        it 'does not update the product\'s units_available' do
          expect { update_request }.not_to(
            change { product.reload.units_available }
          )
        end
      end
    end

    context 'with invalid parameters' do
      context 'when not sending a numeric units_available' do
        let!(:product) { create(:product) }
        let(:params) do
          {
            id: product.id,
            units_available: 'string'
          }
        end
        let(:update_request) { put :update, params: params }

        it 'fails' do
          update_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not update a product' do
          expect { update_request }.not_to(change { Product.count })
        end

        it 'responds with array pointing out the possible errors' do
          update_request
          expect(response_body['error'])
            .to eq(['Units available is not a number.'])
        end
      end

      context 'when not sending a numeric unit_price' do
        let!(:product) { create(:product) }
        let(:params) do
          {
            id: product.id,
            unit_price: 'string'
          }
        end
        let(:update_request) { put :update, params: params }

        it 'fails' do
          update_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a product' do
          expect { update_request }.not_to(change { Product.count })
        end

        it 'responds with array pointing out the possible errors' do
          update_request
          expect(response_body['error'])
            .to eq(['Unit price is not a number.'])
        end
      end
    end

    context 'when the product does not exist' do
      let!(:product) { create(:product) }
      let(:id_param) { { id: product.id + 1 } }
      let(:params) do
        {
          id: id_param
        }
      end

      before { put :update, params: id_param }

      it 'fails' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#destroy' do
    context 'when the product exists' do
      let(:param) { { id: product.id } }
      let(:delete_request) { delete :destroy, params: param }
      let!(:product) { create(:product) }

      it 'succeeds' do
        delete_request
        expect(response).to have_http_status(:ok)
      end

      it 'responds with a message' do
        delete_request
        expect(response_body['message']).to eq('Product successfully deleted.')
      end

      it 'deletes the product' do
        expect { delete_request }.to change { Product.count }.by(-1)
      end
    end

    context 'when the product does not exist' do
      let!(:product) { create(:product) }
      let(:param) { { id: product.id + 1 } }
      let(:delete_request) { delete :destroy, params: param }

      it 'fails' do
        delete_request
        expect(response).to have_http_status(:not_found)
      end

      it 'does not delete the product' do
        expect { delete_request }.not_to(change { Product.count })
      end
    end
  end
end
