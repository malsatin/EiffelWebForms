note
	description: "Server starter"

class
	APPLICATION

inherit
	WSF_DEFAULT_SERVICE[APPLICATION_EXECUTION]
		redefine
			initialize
		end

create
	make_and_launch

feature {NONE} -- Configuration

	default_port: INTEGER = 80
			-- Port number

feature {NONE} -- Initialization

	initialize
			-- Initialises current service
		do
	 		set_service_option ("port", default_port)
	 		set_service_option ("verbose", true)
	 		set_service_option ("force_single_threaded", true)

			import_service_options (create {WSF_SERVICE_LAUNCHER_OPTIONS_FROM_INI}.make_from_file ("stuff/server.ini"))

			Precursor
		end

end
