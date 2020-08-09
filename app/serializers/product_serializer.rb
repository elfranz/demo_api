class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :units_available, :unit_price, :hidden
end
