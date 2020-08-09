class OrderProductSerializer < ActiveModel::Serializer
  attributes :id, :quantity
  belongs_to :product
end
