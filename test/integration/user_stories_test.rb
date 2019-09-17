# frozen_string_literal: true

require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  fixtures :products
  include ActiveJob::TestHelper

  test 'buying a product' do
    start_order_count = Order.count
    ruby_book = products(:ruby)

    # A user goes to the store index page:
    get '/'
    assert_response :success
    assert_select 'h1', 'Your Pragmatic Catalog'

    # He selects a product, adding it to his cart.
    post '/line_items', params: { product_id: ruby_book.id }, xhr: true
    assert_response :success

    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    # He then checks out...
    get '/orders/new'
    assert_response :success
    assert_select 'legend', 'Please Enter Your Details'

    # Creates the order and redirects to the index page
    post orders_url, params: {
      order: {
        name: 'Dave Thomas',
        address: '123 The Street',
        email: 'dave@example.org',
        pay_type: 'Check'
      }
    }
    # follow_redirect!
    assert_response :success
    assert_select 'h2', 'Your Pragmatic Catalog'
    # cart = Cart.find(session[:cart_id])
    # assert_equal 0, cart.line_items.size

    perform_enqueued_jobs do
      # Make sure we’ve created an order and corresponding line item
      # and the details they contain are correct

      assert_equal start_order_count, Order.count
      order = Order.last

      assert_equal 'Dave Thomas', order.name
      assert_equal '123 The Street', order.adress
      assert_equal 'dave@example.org', order.email
      # assert_equal 'Check', order.pay_type

      # assert_equal 1, order.line_items.size
      # line_item = order.line_items[0]
      # assert_equal ruby_book, line_item.product

      # Verify that the mail itself is correctly addressed and has the expected subject line
      # mail = ActionMailer::Base.deliveries.last
      # assert_equal ["dave@example.org"], mail.to
      # assert_equal 'Sam Ruby <depot@example.com>', mail[:from].value
      # assert_equal "Pragmatic Store Order Confirmation", mail.subject
    end
  end
end
