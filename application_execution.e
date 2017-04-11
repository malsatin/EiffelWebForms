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

	db: DATABASE_HELPER

	c_admin: ADMIN_CONTROLLER
	c_api: API_CONTROLLER
	c_report: REPORT_CONTROLLER

feature {NONE}
	-- Initialization

	initialize
			-- Initialize current service.
		do
			create db.my_make ("stuff/webforms.db")

			create c_admin.make (db)
			create c_api.make (db)
			create c_report.make (db)

			Precursor
		end

	setup_router
		-- Setup `router'
			local
				assets_files: WSF_FILE_SYSTEM_HANDLER
			do
				-- Files handler
				create assets_files.make_hidden ("www/assets")
				router.handle ("/assets/", assets_files, router.methods_GET)

				-- Pages routes
				map_uri_agent("/", agent c_report.handle_main, router.methods_GET);
				map_uri_agent("/report/", agent c_report.handle_main, router.methods_GET);
				map_uri_agent("/report/main", agent c_report.handle_main, router.methods_GET);

				map_uri_agent("/report/final", agent c_report.handle_final, router.methods_GET);

				map_uri_template_agent("/report/section/{number}", agent c_report.handle_section, router.methods_GET);

				map_uri_agent("/admin/login", agent c_admin.handle_login, router.methods_GET);
				map_uri_template_agent("/admin/{page}", agent c_admin.handle_page, router.methods_GET);

				map_uri_agent("/api/save-report", agent c_api.handle_save_report, router.methods_get_post);
			end

end
