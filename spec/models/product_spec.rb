require 'rails_helper'

describe Product do
  subject(:product) do
    described_class.new(
      title: Faker::Beer.brand, description: Faker::Beer.style,
      units_available: Faker::Number.number(digits: 3),
      unit_price: Faker::Number.decimal(l_digits: 4, r_digits: 2),
      hidden: false
    )
  end

  it { is_expected.to be_valid }

  it 'is not valid without a title' do
    subject.title = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without units_available' do
    subject.units_available = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without unit_price' do
    subject.unit_price = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without hidden' do
    subject.hidden = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a numeric units available' do
    subject.units_available = 'string'
    expect(subject).to_not be_valid
  end

  it 'is not valid without a positive number units available' do
    subject.units_available = -1
    expect(subject).to_not be_valid
  end

  it 'is not valid without a numeric unit price' do
    subject.unit_price = 'string'
    expect(subject).to_not be_valid
  end

  context 'with factory' do
    subject(:product) do
      create(:product)
    end

    it { is_expected.to be_valid }

    context 'when destroying a product' do
      let!(:order_product) do
        create(:order_product, product: product,
                               quantity: product.units_available)
      end

      it 'should destroy the associated order product' do
        expect { product.destroy }.to change { OrderProduct.count }.by(-1)
      end
    end
  end
end
