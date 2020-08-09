class OrderSerializer < ActiveModel::Serializer
  attributes :id, :customer_id, :created_at, :updated_at
  has_many :order_products

  def created_at
    object.created_at.to_s
  end

  def updated_at
    object.updated_at.to_s
  end
end
