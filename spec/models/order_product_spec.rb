require 'rails_helper'

describe OrderProduct do
  let!(:order) { create(:order) }
  let!(:product) { create(:product) }
  let!(:hidden_product) { create(:product, hidden: true) }

  subject(:order_product) do
    OrderProduct.new(
      order: order, product: product, quantity: product.units_available
    )
  end

  it { is_expected.to be_valid }

  it 'is not valid without a order' do
    subject.order = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a product' do
    subject.product = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a quantity' do
    subject.quantity = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a numerical quantity' do
    subject.quantity = 'string'
    expect(subject).to_not be_valid
  end

  it 'is not valid with quantity more than the total units available' do
    subject.quantity = product.units_available + 1
    expect(subject).to_not be_valid
  end

  it 'is not valid with hidden product' do
    subject.product = hidden_product
    expect(subject).to_not be_valid
  end

  # This is running validations twice and subtracts the units from products
  # context 'with factory' do
  #   context 'with quantity less than the total units avalable' do
  #     subject(:order_product) do
  #       create(:order_product, product: product,
  #                              quantity: product.units_available - 1)
  #     end

  #     it { is_expected.to be_valid }
  #   end
  # end
end
