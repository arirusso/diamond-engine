#!/usr/bin/env ruby
module DiamondEngine
  
  class Sync
    
    attr_reader :queue, :children
    
    def initialize
      @queue ||= {}
      @children ||= []
    end
    
    # sync another <em>syncable</em> to self
    # pass :now => true to queue the sync to happen immediately
    # otherwise the sync will happen at the beginning of self's next sequence
    def add(syncable, options = {})
      @queue[syncable] = options[:now] || false
      true               
    end
    
    # is <em>syncable</em> synced to this instrument?
    def include?(syncable)
      @children.include?(syncable) || @queue.include?(syncable)
    end
    
    # stop sending sync to <em>syncable</em>
    def remove(syncable)
      @children.delete(syncable)
      @queue.delete(syncable)
      syncable.unpause_clock
      true
    end
    
    def tick
      @children.each(&:tick)
    end
    
    # you don't truly hear sync until children are moved from the queue to the children set 
    def activate_queued(force_sync_now)
      updated = false
      @queue.each do |syncable, sync_now|
        if sync_now || force_sync_now 
          @children << syncable
          syncable.pause_clock
          @queue.delete(syncable)
          updated = true
        end
      end
    end
          
  end
  
end