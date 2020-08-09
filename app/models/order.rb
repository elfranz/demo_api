# This model might be considered as unnecessary with the state of the app.
# However, I wanted to make this scalable so in the future, if we need more
# attributes for orders, we'll just add them to this model. The examples that
# come to my mind for example is payment, shipment and delivery information.
class Order < ApplicationRecord
  has_many :order_products, dependent: :destroy
  has_many :products, through: :order_products
  belongs_to :customer
end
