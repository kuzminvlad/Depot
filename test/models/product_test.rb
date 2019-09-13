# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test 'product attribute must not be empty' do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test 'product price must be positive' do
    product = Product.new(title: 'My Book Title',
                          description: 'yyy',
                          image_url: 'zzz.jpg')
    product.price = -1
    assert product.invalid?
    product.price = 0
    assert product.invalid?
    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(title: 'My Book Title',
                description: 'yyy',
                price: 1,
                image_url: image_url)
  end

  test 'image url' do
    ok = %w{fred.gif fred.jpg fred.png FRED.JPG FRRED.JPG
            http://a.b.c./x/x/z/fred.gif}
    bad = %w{fred.doc fred.gif/more fred.gif.more}

    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
    end

    bad.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn't be valid"
    end
  end

  test 'product is not valid without a unique title' do
    product = Product.new(title: products(:ruby).title,
                          description: 'yyy',
                          price: 1,
                          image_url: 'fred.gif')
    assert !product.save
  end

end
