# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

customer = Customer.create(
  email: Faker::Internet.email,
  name: Faker::Name.name_with_middle,
  document_number: Faker::Number.number(digits: 8),
  phone_number: Faker::Number.number(digits: 11),
  address: Faker::Address.street_address
)

product = Product.create(
  title: Faker::Beer.brand,
  description: Faker::Beer.style,
  units_available: Faker::Number.number(digits: 5),
  unit_price: Faker::Number.decimal(l_digits: 4, r_digits: 2),
  hidden: false
)

another_product = Product.create(
  title: Faker::Beer.brand,
  description: Faker::Beer.style,
  units_available: Faker::Number.number(digits: 3),
  unit_price: Faker::Number.decimal(l_digits: 4, r_digits: 2),
  hidden: false
)

order = Order.create(
  customer: customer
)

OrderProduct.create(
  product: product, order: order, quantity: product.units_available - 100
)
