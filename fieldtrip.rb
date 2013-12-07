require 'socket'

class FieldTrip
  VERSION = 1
  GET_HDR = 0x201
  GET_DAT = 0x202
  GET_EVT = 0x203
  WAIT_DAT = 0x402

  class Client
    def initialize(hostname, port = 1972)
      @socket = TCPSocket.new hostname, port
    end

    def send_request(command, payload = nil)
      if payload.nil?
        request = [VERSION, command, 0].pack('vvV')
      else
        request = [VERSION, command, payload.bytesize].pack('vvV') + payload
      end

      @socket.write request
    end

    def receive_response
      response_header = @socket.read(8)
      _, _, bufsize = response_header.unpack('vvV')

      response_body = @socket.read(bufsize)

      return response_header + response_body
    end

    def get_header
      send_request GET_HDR
      receive_response
    end

    def get_data(begsample = nil, endsample = nil)
      if begsample.nil? && endsample.nil?
        send_request GET_DAT
      else
        send_request GET_DAT, [begsample, endsample].pack('LL')
      end

      receive_response
    end

    def get_events(begevent = nil, endevent = nil)
      if begevent.nil? && endevent.nil?
        send_request GET_EVT
      else
        send_request GET_EVT, [begevent, endevent].pack('LL')
      end

      receive_response
    end

    def wait_data(nsamples, nevents, timeout)
      send_request WAIT_DAT, [nsamples, nevents, timeout].pack('LLL')
      receive_response
    end
  end
end