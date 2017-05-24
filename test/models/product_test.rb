require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products
  
  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
  end
  
  test "product price must be positive" do
    product = Product.new(title: "Test_Bread",
                          description: "Bread for testing",
                          leadtime: 0)
    product.price = -1
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"],
      product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"],
      product.errors[:price]

    product.price = 1
    assert product.valid?
  end
  
  test "product is not valid without a unique title" do
    product = Product.new(title: products(:bread).title,
                          description: "duplicate bread",
                          price: 1.00,
                          leadtime: 0)
    assert product.invalid?
    assert_equal ["has already been taken"], product.errors[:title]
  end
  
end
