# frozen_string_literal: true

require_relative '../../test_helper'
require 'phonelib'

class TestFakerPhone < Test::Unit::TestCase
  def setup
    @tester = Faker::PhoneNumber
    @phone_with_country_code_regex = /\A\+(\s|\d|-|\(|\)|x|\.)*\z/
  end

  def test_country_code
    assert_match(/\A\+[\d|-]+\z/, @tester.country_code)
  end

  def test_phone_number_with_country_code
    assert_match @phone_with_country_code_regex, @tester.phone_number_with_country_code
  end

  def test_cell_phone_with_country_code
    assert_match @phone_with_country_code_regex, @tester.cell_phone_with_country_code
  end

  def test_cell_phone_in_e164
   100.times do
      result = @tester.cell_phone_in_e164
      p Phonelib.valid? result
      assert_equal(12, @tester.cell_phone_in_e164.length)
      assert_match @phone_with_country_code_regex, @tester.cell_phone_in_e164
   end
  end
end
