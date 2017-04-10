note
	description: "Summary description for {APPLICATION_EXECUTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION_EXECUTION

inherit

	WSF_ROUTED_EXECUTION
		redefine
			initialize
		end

	WSF_ROUTED_URI_TEMPLATE_HELPER
	WSF_ROUTED_URI_HELPER

create
	make

feature
	-- Common

	db_conn: SQLITE_DATABASE

	c_admin: ADMIN_CONTROLLER
	c_api: API_CONTROLLER
	c_report: REPORT_CONTROLLER

feature {NONE}
	-- Initialization

	initialize
			-- Initialize current service.
		do
			create db_conn.make_open_read_write ("stuff/webforms.db")
			if db_conn.has_error then
				if attached db_conn.last_exception AS exception then
					Io.put_string ("DB error #" + exception.extended_code.out)
				else
					Io.put_string ("Undefined DB error")
				end
			end

			create c_admin.make (db_conn)
			create c_api.make (db_conn)
			create c_report.make (db_conn)

			Precursor
		end

	setup_router
		-- Setup `router'
			local
				assets_files: WSF_FILE_SYSTEM_HANDLER
			do
				--create doc.make (router)
				--router.handle ("/api/doc", doc, router.methods_GET)
				--map_uri_template_agent ("/api/message/time/now", agent handle_time_now_utc, router.methods_GET)
				--map_uri_template_agent ("/api/message/hover/{name}", agent handle_hover_message, router.methods_GET)
				--map_uri_template_agent ("/api/session/{session}/item/{name}", agent handle_interface_id_set_value, router.methods_POST)
				--map_uri_template_agent ("/api/session/{session}/item/{name}", agent handle_interface_id_get_text, router.methods_GET)
				--map_uri_template_agent ("/api/{operation}", agent handle_api, router.all_allowed_methods)

				create assets_files.make_hidden ("www/assets")
				router.handle ("/assets/", assets_files, router.methods_GET)

				map_uri_agent("/", agent c_report.handle_main, router.methods_GET);
				map_uri_agent("/report/", agent c_report.handle_main, router.methods_GET);
				map_uri_agent("/report/main", agent c_report.handle_main, router.methods_GET);

				map_uri_agent("/report/final", agent c_report.handle_final, router.methods_GET);

				map_uri_template_agent("/report/section/{number}", agent c_report.handle_section, router.methods_GET);

				map_uri_agent("/admin/login", agent c_admin.handle_login, router.methods_GET);
				map_uri_template_agent("/admin/{page}", agent c_admin.handle_page, router.methods_GET);
			end

end
