require 'rails_helper'

describe Order do
  subject(:order) do
    create(:order)
  end

  it { is_expected.to be_valid }

  context 'when destroying the order' do
    let!(:product) { create(:product) }
    let!(:order_product) do
      create(
        :order_product, order: order, product: product,
                        quantity: product.units_available - 1
      )
    end

    it 'should destroy the associated order product' do
      expect { order.destroy }.to change { OrderProduct.count }.by(-1)
    end
  end

  context 'when not given a customer id' do
    subject do
      described_class.new(customer_id: nil)
    end

    it 'should not be saved' do
      expect(subject.save).to be(false)
    end
  end
end
