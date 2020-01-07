# frozen_string_literal: true

require 'test_helper'

class StrainerTemplateUnitTest < Minitest::Test
  include Liquid

  def test_add_filter_when_wrong_filter_class
    c = Context.new
    s = c.strainer
    wrong_filter = ->(v) { v.reverse }

    exception = assert_raises(TypeError) do
      s.class.add_filter(wrong_filter)
    end
    assert_equal(exception.message, "wrong argument type Proc (expected Module)")
  end
end
