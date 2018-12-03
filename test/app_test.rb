require 'test_helper'

class AppTest < Minitest::Test
  def env
    Rack::MockRequest.env_for('/')
  end

  def test_querying_view_will_raise_exception
    begin
      FooController.action(:querying).call(env)
    rescue Exception => e
      @exception = e
    end
    assert_equal NoQueryingViewError, @exception.class
  end

  def test_non_querying_view_wont_raise
    status, headers, body = FooController.action(:non_querying).call(env)
    response = ActionDispatch::TestResponse.new(status, headers, body)

    assert_equal      200, response.status
    assert_equal "test\n", response.body
  end
end
