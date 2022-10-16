# frozen_string_literal: true

require_relative 'test_helper'
# rubocop:disable Security/Eval,Style/EvalWithLocation
class TestDeterminism < Test::Unit::TestCase
  def setup
    @all_methods = all_methods.freeze
    @first_run = []
  end

  def test_determinism
    Faker::Config.random = Random.new(42)
    @all_methods.each_index do |index|
      store_result @all_methods[index]
    end

    @first_run.freeze

    Faker::Config.random = Random.new(42)
    @all_methods.each_index do |index|
      assert deterministic_random? @first_run[index], @all_methods[index]
    end
  end

  def test_thread_safety
    expected_values = 2.times.map do |index|
      Faker::Config.random = Random.new(index)
      Faker::Number.digit
    end

    threads = expected_values.each_with_index.map do |expected_value, index|
      Thread.new do
        100_000.times.each do
          Faker::Config.random = Random.new(index)
          output = Faker::Number.digit

          assert_equal output, expected_value
        end
      end
    end

    threads.each(&:join)
  end

  def test_locale_setting
    # if locale is not set, fallback to :en
    assert_equal :en, Faker::Config.locale

    # locale can be updated initially
    # and it becomes the default value
    # for new threads
    Faker::Config.locale = :pt

    assert_equal :pt, Faker::Config.locale

    t1 = Thread.new do
      # child thread has initial locale equal to
      # latest locale set on main thread
      # instead of the fallback value
      assert_equal :pt, Faker::Config.locale
      refute_equal :en, Faker::Config.locale

      # child thread can set its own locale
      Faker::Config.locale = :es
      assert_equal :es, Faker::Config.locale
    end

    t1.join

    # child thread won't change locale of other threads
    assert_equal :pt, Faker::Config.locale

    t2 = Thread.new do
      # initial default locale is copied over to new thread
      assert_equal :pt, Faker::Config.locale

      Faker::Config.locale = :it
      assert_equal :it, Faker::Config.locale
    end

    t2.join

    assert_equal :pt, Faker::Config.locale
  end

  private

  def deterministic_random?(first, method_name)
    second = eval(method_name)
    (first == second) || raise(
      "#{method_name} has an entropy leak; use \"Faker::Config.random.rand\" or \"Array#sample(random: Faker::Config.random)\". Method to lookup for: sample, shuffle, rand"
    )
  end

  def store_result(method_name)
    @first_run << eval(method_name)
  rescue StandardError => e
    raise %(#{method_name} raised "#{e}")
  end

  def all_methods
    subclasses.map do |subclass|
      subclass_methods(subclass).flatten
    end.flatten.sort
  end

  def subclasses
    Faker.constants.delete_if do |subclass|
      %i[Base Bank Books Cat Char Base58 ChileRut CLI Config Creature Date Dog DragonBall Dota ElderScrolls Fallout Games GamesHalfLife HeroesOfTheStorm Internet JapaneseMedia LeagueOfLegends Movies Myst Overwatch OnePiece Pokemon Religion Sports SwordArtOnline TvShows Time VERSION Witcher WorldOfWarcraft Zelda].include?(subclass)
    end.sort
  end

  def subclass_methods(subclass)
    eval("Faker::#{subclass}.public_methods(false) - Faker::Base.public_methods(false)").sort.map do |method|
      "Faker::#{subclass}.#{method}"
    end.sort
  end
end
# rubocop:enable Security/Eval,Style/EvalWithLocation
