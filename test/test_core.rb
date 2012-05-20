require 'test/unit'
require 'fileutils'
require 'mc-limit'

class TC_Default_Minutes < Test::Unit::TestCase
  def setup
    ENV.delete 'DEFAULT_MC_LIMIT'
  end

  def test_return_hardcoded_default_when_env_not_set
    assert_equal MCLimit::DEFAULT_MINUTES, MCLimit.default_minutes
  end

  def test_return_env_value_when_set
    ENV['DEFAULT_MC_LIMIT'] = '2112'
    assert_equal 2112, MCLimit.default_minutes
  end
end

class TC_Remaining_Minutes < Test::Unit::TestCase
  def setup
    FileUtils.rm_f( MCLimit::REMAINING_FILE )
    ENV.delete 'DEFAULT_MC_LIMIT'
  end
  def teardown
    FileUtils.rm_f( MCLimit::REMAINING_FILE )
  end

  def test_return_hardcoded_default_when_file_missing_and_env_not_set
    assert_equal MCLimit::DEFAULT_MINUTES, MCLimit.remaining_minutes
  end

  def test_return_env_default_when_file_missing
    ENV['DEFAULT_MC_LIMIT'] = '74'
    assert_equal 74, MCLimit.remaining_minutes
  end

  def test_return_file_defined_minutes_if_file_contains_todays_date
    yaml = { :date => Date.new(1776, 7, 4), :remaining => 13 }.to_yaml
    File.open(MCLimit::REMAINING_FILE, 'wt') { |f| f.write( yaml ) }
    assert_equal 13, MCLimit.remaining_minutes( Date.new(1776, 7, 4) )
  end

  def test_return_default_minutes_if_file_contains_different_date
    yaml = { :date => Date.new(1776, 7, 4), :remaining => 13 }.to_yaml
    File.open(MCLimit::REMAINING_FILE, 'wt') { |f| f.write( yaml ) }
    assert_equal MCLimit.default_minutes, MCLimit.remaining_minutes
  end

  def test_return_default_minutes_if_file_contains_garbage_date
    yaml = { :date => 'garbage', :remaining => 13 }.to_yaml
    File.open(MCLimit::REMAINING_FILE, 'wt') { |f| f.write( yaml ) }
    assert_equal MCLimit.default_minutes, MCLimit.remaining_minutes
  end

  def test_return_default_minutes_if_file_contains_garbage_minutes
    yaml = { :date => Date.new(1776, 7, 4), :remaining => 'garbage' }.to_yaml
    File.open(MCLimit::REMAINING_FILE, 'wt') { |f| f.write( yaml ) }
    assert_equal MCLimit.default_minutes, MCLimit.remaining_minutes( Date.new(1776, 7, 4) )
  end

  def test_return_default_minutes_if_file_contains_garbage
    File.open(MCLimit::REMAINING_FILE, 'wt') { |f| f.write( 'garbage' ) }
    assert_equal MCLimit.default_minutes, MCLimit.remaining_minutes
  end
end

class TC_Update_Remaining_Minutes < Test::Unit::TestCase
  def setup
    FileUtils.rm_f( MCLimit::REMAINING_FILE )
    ENV.delete 'DEFAULT_MC_LIMIT'
  end
  def teardown
    FileUtils.rm_f( MCLimit::REMAINING_FILE )
  end

  def test_writes_current_date_and_given_minutes_to_file
    MCLimit.update_remaining_minutes 42
    assert_equal( { :date => Date.today, :remaining => 42 },
      YAML.load_file(MCLimit::REMAINING_FILE) )
  end
end

# vim:ts=2:sw=2:et
