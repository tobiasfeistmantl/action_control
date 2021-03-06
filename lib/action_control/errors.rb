# @author Tobias Feistmantl
module ActionControl
	# Generic authorization error.
	# Other, more specific, errors inherit from this one.
	#
	# @raise [AuthorizationError]
	#    if something generic is happening.
	class AuthorizationError < StandardError
	end

	# Error for controllers in which authorization isn't handled.
	#
	# @raise [AuthorizationNotPerformedError]
	#    if the #authorized? method isn't defined
	#    in the controller class.
	class AuthorizationNotPerformedError < AuthorizationError
	end

	# Error if user unauthorized.
	#
	# @raise [NotAuthorizedError]
	#    if authorized? isn't returning true.
	#
	# @note
	#    Should always be called at the end
	#    of the #authorize! method.
	class NotAuthorizedError < AuthorizationError
		attr_reader :error

		def initialize(error={})
			@error = error
		end
	end


	# Base class for authentication errors.
	#
	# @raise [AuthenticationError]
	#    if something generic happens.
	class AuthenticationError < StandardError
	end

	# Error for controllers in which authentication isn't handled.
	#
	# @raise [AuthenticationNotPerformedError]
	#    if the #authenticated? method isn't defined
	#    in the controller class.
	class AuthenticationNotPerformedError < AuthenticationError
	end

	# Error if user not authenticated
	#
	# @raise [NotAuthenticatedError]
	#    if authenticated? isn't returning true.
	#
	# @note
	#    Should always be called at the end
	#    of the #authenticate! method.
	class NotAuthenticatedError < AuthenticationError
		attr_reader :error

		def initialize(error={})
			@error = error
		end
	end
end