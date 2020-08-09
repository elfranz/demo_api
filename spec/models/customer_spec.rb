require 'rails_helper'

describe Customer do
  subject(:customer) do
    described_class.new(
      email: Faker::Internet.email, name: Faker::Name.name_with_middle,
      document_number: Faker::Number.number(digits: 8),
      phone_number: Faker::Number.number(digits: 11),
      address: Faker::Address.street_address
    )
  end

  it { is_expected.to be_valid }

  it 'is not valid without a name' do
    subject.name = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a email' do
    subject.email = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a document number' do
    subject.document_number = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a phone number' do
    subject.phone_number = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a address' do
    subject.address = nil
    expect(subject).to_not be_valid
  end

  it 'is not valid without a numeric document number' do
    subject.document_number = 'string'
    expect(subject).to_not be_valid
  end

  it 'is not valid without a numeric phone number' do
    subject.phone_number = 'string'
    expect(subject).to_not be_valid
  end

  context 'when trying to create a customer with existen document number' do
    before do
      described_class.create!(
        email: Faker::Internet.email, name: Faker::Name.name_with_middle,
        document_number: customer.document_number,
        phone_number: Faker::Number.number(digits: 11),
        address: Faker::Address.street_address
      )
    end

    it 'is not valid if the document number is not unique' do
      expect(subject).to be_invalid
    end
  end

  context 'with factory' do
    subject(:customer) do
      create(:customer)
    end

    it { is_expected.to be_valid }
  end
end
