# Marker module for UnixSocks server-related errors.
#
# This module is mixed into exceptions raised by UnixSocks server
# implementations to provide a common rescue clause for server-related
# errors.
#
# @example Handling server errors
#   begin
#     server.receive { |message| process_message(message) }
#   rescue UnixSocks::ServerError
#     # Handle all UnixSocks server errors consistently
#   end
module UnixSocks::ServerError
  # Builds a server error exception with the given exception class and message.
  #
  # This method creates a new exception instance of the specified exception
  # class with the provided message, marks it with the ServerError module, and
  # returns the marked exception.
  #
  # @param exception [ Class ] The exception class to be instantiated
  # @param message [ String ] The error message for the exception
  #
  # @return [ Exception ] A new exception instance marked with ServerError module
  def self.build(exception, message)
    mark(exception.new(message))
  end

  # Marks the given exception with the ServerError module.
  #
  # This method extends the provided exception object with the ServerError
  # module, effectively tagging it as a server-related error for consistent
  # handling.
  #
  # @param e [ Exception ] The exception object to be marked
  #
  # @return [ Exception ] The same exception object, now extended with ServerError
  def self.mark(e)
    e.extend(self)
  end
end
