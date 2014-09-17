module MIDIInstrument

  # Helper for converting MIDI messages
  module Message

    extend self

    # Convert the input to MIDI messages
    # @param [Array<MIDIMessage>, Array<String>, MIDIMessage, *MIDIMessage, String] args
    # @return [Array<MIDIMessage>]
    def to_messages(*args)
      data = [args.dup].flatten
      if data.all? { |item| note?(item) }
        Message.to_note_ons(*data) # string note names
      elsif data.all? { |item| message?(item) }
        data # messages
      end
    end

    # Convert the input to bytes
    # @param [Array<Fixnum>, Array<MIDIMessage>, Array<String>, MIDIMessage, *MIDIMessage, String] args
    # @return [Array<Fixnum>]
    def to_bytes(*args)
      messages = to_messages(*args)
      if !messages.nil?
        messages.map(&:to_bytes).flatten
      elsif args.all? { |arg| bytes?(arg)}
        args
      end
    end

    # Convert the input to MIDI note on messages
    # @param [*MIDIMessage::NoteOn, *String] args
    # @param [Hash] options
    # @option options [Fixnum] :default_channel
    # @option options [Fixnum] :default_velocity
    # @return [Array<MIDIMessage::NoteOn, nil>]
    def to_note_ons(*args)
      notes = [args.dup].flatten
      options = notes.last.kind_of?(Hash) ? notes.pop : {}
      notes.map do |note|
        case note
        when String then string_to_note_on(note, options) if note?(note)
        when MIDIMessage::NoteOn then note
        end
      end
    end

    private

    # Does this object look like a MIDI byte?
    # @param [Object] object
    # @return [Boolean]
    def bytes?(object)
      object.kind_of?(Fixnum) && object >= 0x00 && object <= 0xFF
    end

    # Is this object a MIDI message?
    # @param [Object] object
    # @return [Boolean]
    def message?(object)
      object.class.name.match(/\AMIDIMessage::[a-zA-Z]+\z/)
    end

    # Is this object a string note name? eg "A4"
    # @param [Object] object
    # @return [Boolean]
    def note?(object)
      object.kind_of?(String) && object.match(/\A[a-zA-Z]{1}(\#|b)?\-?\d{1}\z/)
    end

    # Convert the given string (eg "A4") to a note on message object
    # @param [String] string
    # @param [Hash] options
    # @option options [Fixnum] :default_channel
    # @option options [Fixnum] :default_velocity
    # @return [MIDIMessage::NoteOn]
    def string_to_note_on(string, options = {})
      channel = options.fetch(:default_channel, 0)
      velocity = options.fetch(:default_velocity, 100)
      MIDIMessage::NoteOn[string].new(channel, velocity)
    end

  end

end

