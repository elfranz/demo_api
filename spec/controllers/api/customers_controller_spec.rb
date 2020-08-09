require 'rails_helper'

describe Api::CustomersController do
  describe '#index' do
    let!(:customers) { create_list(:customer, 10) }

    before { get :index }

    it 'succeeds' do
      expect(response).to have_http_status(:ok)
    end

    it 'responds with all the customers' do
      expect(response_body.size).to eq(Customer.all.size)
    end

    it 'responds with customers information' do
      expect(response_body.first.keys)
        .to eq(%w[id email name document_number phone_number address])
    end
  end

  describe '#show' do
    before { get :show, params: param }

    context 'when the customer exists' do
      let!(:customer) { create(:customer) }
      let(:param) { { id: customer.id } }

      it 'succeeds' do
        expect(response).to have_http_status(:ok)
      end

      it 'responds with the created customer\'s id' do
        expect(response_body['id']).to eq(customer.id)
      end

      it 'responds with the created customer\'s email' do
        expect(response_body['email']).to eq(customer.email)
      end

      it 'responds with the created customer\'s name' do
        expect(response_body['name']).to eq(customer.name)
      end

      it 'responds with the created customer\'s document number' do
        expect(response_body['document_number'])
          .to eq(customer.document_number)
      end

      it 'responds with the created customer\'s phone_number' do
        expect(response_body['phone_number'])
          .to eq(customer.phone_number)
      end

      it 'responds with the created customer\'s address' do
        expect(response_body['address']).to eq(customer.address)
      end
    end

    context 'when the customer does not exist' do
      let!(:customer) { create(:customer) }
      let(:param) { { id: customer.id + 1 } }

      it 'fails' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    context 'with valid params' do
      let(:customer_params) { attributes_for(:customer) }
      let(:create_request) { post :create, params: customer_params }

      it 'succeeds' do
        create_request
        expect(response).to have_http_status(:created)
      end

      it 'creates a customer' do
        expect { create_request }.to change{ Customer.count }.by(1)
      end

      it 'responds with the created customer\'s id' do
        create_request
        expect(response_body['id']).to eq(Customer.last.id)
      end

      it 'responds with the created customer\'s email' do
        create_request
        expect(response_body['email']).to eq(customer_params[:email])
      end

      it 'responds with the created customer\'s name' do
        create_request
        expect(response_body['name']).to eq(customer_params[:name])
      end

      it 'responds with the created customer\'s document number' do
        create_request
        expect(response_body['document_number'])
          .to eq(customer_params[:document_number])
      end

      it 'responds with the created customer\'s phone_number' do
        create_request
        expect(response_body['phone_number'])
          .to eq(customer_params[:phone_number])
      end

      it 'responds with the created customer\'s address' do
        create_request
        expect(response_body['address']).to eq(customer_params[:address])
      end
    end

    context 'with invalid params' do
      context 'when sending a string to document number' do
        let(:customer_params) do
          {
            email: Faker::Internet.email,
            name: Faker::Name.name_with_middle,
            document_number: 'string',
            phone_number: Faker::Number.number(digits: 11),
            address: Faker::Address.street_address
          }
        end
        let(:create_request) { post :create, params: customer_params }

        it 'fails' do
          create_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a customer' do
          expect { create_request }.not_to(change { Customer.count })
        end

        it 'responds with array pointing out the possible errors' do
          create_request
          expect(response_body['error'])
            .to eq(['Document number is not a number.'])
        end
      end

      context 'when sending a string to phone number' do
        let(:customer_params) do
          {
            email: Faker::Internet.email,
            name: Faker::Name.name_with_middle,
            document_number: Faker::Number.number(digits: 8),
            phone_number: 'string',
            address: Faker::Address.street_address
          }
        end
        let(:create_request) { post :create, params: customer_params }

        it 'fails' do
          create_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a customer' do
          expect { create_request }.not_to(change { Customer.count })
        end

        it 'responds with array pointing out the possible errors' do
          create_request
          expect(response_body['error'])
            .to eq(['Phone number is not a number.'])
        end
      end

      context 'when sending an existent document_number' do
        let!(:customer) { create(:customer) }
        let(:customer_params) do
          {
            email: Faker::Internet.email,
            name: Faker::Name.name_with_middle,
            document_number: customer.document_number,
            phone_number: Faker::Number.number(digits: 11),
            address: Faker::Address.street_address
          }
        end
        let(:create_request) { post :create, params: customer_params }

        it 'fails' do
          create_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a customer' do
          expect { create_request }.not_to(change { Customer.count })
        end

        it 'responds with array pointing out the possible errors' do
          create_request
          expect(response_body['error'])
            .to eq(['Document number has already been taken.'])
        end
      end
    end

    context 'with missing required param' do
      let(:customer_params) { attributes_for(:customer) }
      let(:create_request) do
        post :create, params: customer_params.except(
          customer_params.keys.sample
        )
      end

      it 'fails' do
        create_request
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a customer' do
        expect { create_request }.not_to(change { Customer.count })
      end

      it 'responds with an error message' do
        create_request
        expect(response_body['error'])
          .to eq('Missing required param.')
      end
    end
  end

  describe '#update' do
    context 'when the customer exists' do
      context 'when sending all the parameters' do
        let!(:customer) { create(:customer) }
        let(:params) do
          {
            id: customer.id,
            email: Faker::Internet.email,
            name: Faker::Name.name_with_middle,
            document_number: Faker::Number.number(digits: 8),
            phone_number: Faker::Number.number(digits: 11),
            address: Faker::Address.street_address
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

        it 'updates the customer\'s email' do
          expect { update_request }.to change { customer.reload.email }
            .to(params[:email])
        end

        it 'updates the customer\'s name' do
          expect { update_request }.to change { customer.reload.name }
            .to(params[:name])
        end

        it 'updates the customer\'s document number' do
          expect { update_request }
            .to change { customer.reload.document_number }
            .to(params[:document_number])
        end

        it 'updates the customer\'s phone number' do
          expect { update_request }.to change { customer.reload.phone_number }
            .to(params[:phone_number])
        end

        it 'updates the customer\'s address' do
          expect { update_request }.to change { customer.reload.address }
            .to(params[:address])
        end
      end

      context 'when sending some parameters' do
        let!(:customer) { create(:customer) }
        let(:params) do
          {
            id: customer.id,
            email: Faker::Internet.email,
            name: Faker::Name.name_with_middle
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

        it 'updates the customer\'s email' do
          expect { update_request }.to change { customer.reload.email }
            .to(params[:email])
        end

        it 'updates the customer\'s name' do
          expect { update_request }.to change { customer.reload.name }
            .to(params[:name])
        end

        it 'does not update the customer\'s document number' do
          expect { update_request }.not_to(
            change { customer.reload.document_number }
          )
        end

        it 'does not update the customer\'s phone number' do
          expect { update_request }.not_to(
            change { customer.reload.phone_number }
          )
        end

        it 'does not update the customer\'s address' do
          expect { update_request }.not_to(
            change { customer.reload.address }
          )
        end
      end
    end

    context 'with invalid parameters' do
      context 'when not sending a numeric document number' do
        let!(:customer) { create(:customer) }
        let(:params) do
          {
            id: customer.id,
            document_number: 'string'
          }
        end
        let(:update_request) { put :update, params: params }

        it 'fails' do
          update_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not update the document number' do
          expect { update_request }.not_to(change { customer.document_number })
        end

        it 'responds with array pointing out the possible errors' do
          update_request
          expect(response_body['error'])
            .to eq(['Document number is not a number.'])
        end
      end

      context 'when not sending a numeric phone number' do
        let!(:customer) { create(:customer) }
        let(:params) do
          {
            id: customer.id,
            phone_number: 'string'
          }
        end
        let(:update_request) { put :update, params: params }

        it 'fails' do
          update_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not update the document number' do
          expect { update_request }.not_to(change { customer.document_number })
        end

        it 'responds with array pointing out the possible errors' do
          update_request
          expect(response_body['error'])
            .to eq(['Phone number is not a number.'])
        end
      end

      context 'when sending an existent document number' do
        let!(:customer) { create(:customer) }
        let!(:other_customer) { create(:customer) }
        let(:params) do
          {
            id: customer.id,
            document_number: other_customer.document_number
          }
        end
        let(:update_request) { put :update, params: params }

        it 'fails' do
          update_request
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not update the document number' do
          expect { update_request }.not_to(change { customer.document_number })
        end

        it 'responds with array pointing out the possible errors' do
          update_request
          expect(response_body['error'])
            .to eq(['Document number has already been taken.'])
        end
      end
    end

    context 'when the customer does not exist' do
      let!(:customer) { create(:customer) }
      let(:id_param) { customer.id + 1 }
      let(:params) do
        {
          id: id_param,
          email: Faker::Internet.email,
          name: Faker::Name.name_with_middle
        }
      end

      before { put :update, params: params  }

      it 'fails' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#destroy' do
    context 'when the customer exists' do
      let(:param) { { id: customer.id } }
      let(:delete_request) { delete :destroy, params: param }
      let!(:customer) { create(:customer) }

      it 'succeeds' do
        delete_request
        expect(response).to have_http_status(:ok)
      end

      it 'responds with a message' do
        delete_request
        expect(response_body['message']).to eq('Customer successfully deleted.')
      end

      it 'deletes the customer' do
        expect { delete_request }.to change { Customer.count }.by(-1)
      end
    end

    context 'when the customer does not exist' do
      let!(:customer) { create(:customer) }
      let(:param) { { id: customer.id + 1 } }
      let(:delete_request) { delete :destroy, params: param }

      it 'fails' do
        delete_request
        expect(response).to have_http_status(:not_found)
      end

      it 'does not delete the customer' do
        expect { delete_request }.not_to(change { Customer.count })
      end
    end
  end
end
