#!/usr/bin/env ruby

require 'helper'

class SyncSchemeTest < Test::Unit::TestCase

  include Inst
  include MIDIMessage
  include TestHelper
  
  def test_add
    s1 = SyncScheme.new
    s2 = MIDISequencer.new(127)
    assert_equal(false, s1.include?(s2))
    s1.add(s2)
    assert_equal(true, s1.include?(s2))
  end

  def test_remove
    s1 = SyncScheme.new
    s2 = MIDISequencer.new(127)
    assert_equal(false, s1.include?(s2))
    s1.add(s2)
    assert_equal(true, s1.include?(s2))
    s1.remove(s2)
    assert_equal(false, s1.include?(s2))
  end
  
  def test_activate_now
    
  end
  
  def test_activate_later
    
  end
  
  
    
end