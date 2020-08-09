class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :document_number, :phone_number, :address
end
