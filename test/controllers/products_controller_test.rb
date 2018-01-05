require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get sort" do
    get products_sort_url
    assert_response :success
  end

end
