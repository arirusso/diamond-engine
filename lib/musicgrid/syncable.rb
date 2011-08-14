#!/usr/bin/env ruby
module MusicGrid
  
  module Syncable
    
    def self.included(base)
      base.send(:attr_reader, :sync_set)
    end
    
    # sync another <em>syncable</em> to self
    # pass :now => true to queue the sync to happen immediately
    # otherwise the sync will happen at the beginning of self's next sequence
    def sync(syncable, options = {})
      return false if @sync_set.include?(syncable) || syncable.sync_set.include?(self)      
      @sync_queue[syncable] = options[:now] || false
      true               
    end
        
    # receive sync from <em>syncable</em>
    def sync_to(syncable, options = {})
      syncable.sync(self, options)
    end
    
    # stop sending sync to <em>syncable</em>
    def unsync(syncable)
      return false unless @sync_set.include?(syncable)
      @sync_set.delete(syncable)
      syncable.unpause_clock
      on_sync_updated
      true
    end
    
    # stop receiving sync from <em>syncable</em>
    def unsync_from(syncable)
      syncable.unsync(self)
    end
    
    def sync_tick
      @actions[:tick].call
    end
    
    # disable internal clock
    def pause_clock
      @clock.pause
    end
    
    # enable internal clock
    def unpause_clock
      @clock.unpause
    end
    
    private
    
    def initialize_syncable(sync_to, sync)
      @sync_queue ||= {}
      @sync_set ||= []
      unless sync_to.nil?
        sync_to = [sync_to].flatten.compact      
        sync_to.each { |syncable| sync_to(syncable) }
      end
      unless sync.nil?
        sync = [sync].flatten.compact
        sync.each { |syncable| sync(syncable) }
      end
    end
    
    def activate_sync_queue(now)
      updated = false
      @sync_queue.each do |syncable, sync_now|
        if sync_now || now 
          @sync_set << syncable
          syncable.pause_clock
          @sync_queue.delete(syncable)
          updated = true
        end
      end      
      on_sync_updated if updated
    end
          
  end
  
end
