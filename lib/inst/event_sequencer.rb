#!/usr/bin/env ruby
module Inst

  module EventSequencer
    
    # bind an event that occurs every time the clock ticks
    def on_tick(&block)
      @events[:tick] = block
    end
    
    # bind an event that occurs on start
    def on_start(&block)
      @events[:start] = block
    end
    
    # bind an event that occurs on stop
    def on_stop(&block)
      @events[:stop] = block
    end 

    # bind an event where if it evaluates to true, no messages will be outputted during that
    # step. (however, the tick event will still be fired)
    # Arpeggiator#sequence is passed to the block
    def rest_when(&block)
      @events[:rest_when] = block
    end
    
    # should the arpeggiator rest on the current step?
    def rest?
      @events[:rest_when].nil? ? false : @events[:rest_when].call(@sequence) 
    end
    
    # bind an event where the arpeggiator plays a rest on every <em>num<em> beat
    # passing in nil will cancel any rest events 
    def rest_every(num)
      num.nil? ? @events[:rest_when] = nil : rest_when { |s| s.pointer % num == 0 }
      true
    end

    # bind an event where the arpeggiator resets on every <em>num<em> beat
    # passing in nil will cancel any reset events 
    def reset_every(num)
      num.nil? ? @events[:reset_when] = nil : reset_when { |s| s.pointer % num == 0 }
      true
    end
        
    # remove all note-on messages
    def rest_event_filter(msgs)
      msgs.delete_if { |m| m.class == MIDIMessage::NoteOn }
    end

    # if it evaluates to true, the sequence will go back to step 0
    # Arpeggiator#sequence is passed to the block  
    def reset_when(&block)
      @events[:reset_when] = block
    end
    
    # should the arpeggiator reset on the current step?
    def reset?
      @events[:reset_when].nil? ? false : @events[:reset_when].call(@sequence) 
    end
    
    private
    
    def initialize_event_sequencer
      @events ||= {}
    end
        
  end
  
end
