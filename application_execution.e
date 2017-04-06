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

	WSF_URI_TEMPLATE_HELPER_FOR_ROUTED_EXECUTION

create
	make

feature {NONE} -- Initialization

	initialize
			-- Initialize current service.
		do
			Precursor

			-- TODO: connect to DB
		end

	setup_router
		-- Setup `router'
			local
				assets_files: WSF_FILE_SYSTEM_HANDLER
				common_files: WSF_FILE_SYSTEM_HANDLER
				--doc: WSF_ROUTER_SELF_DOCUMENTATION_HANDLER
			do
				--create doc.make (router)
				--router.handle ("/api/doc", doc, router.methods_GET)
				--map_uri_template_agent ("/api/message/time/now", agent handle_time_now_utc, router.methods_GET)
				--map_uri_template_agent ("/api/message/hover/{name}", agent handle_hover_message, router.methods_GET)
				--map_uri_template_agent ("/api/session/{session}/item/{name}", agent handle_interface_id_set_value, router.methods_POST)
	--			map_uri_template_agent ("/api/session/{session}/item/{name}", agent handle_interface_id_get_text, router.methods_GET)
				--map_uri_template_agent ("/api/{operation}", agent handle_api, router.all_allowed_methods)
				create assets_files.make_hidden ("www/assets")
				router.handle ("/asset/", assets_files, router.methods_GET)

				create common_files.make_hidden ("www")
				common_files.set_directory_index (<<"home.html">>)
				router.handle ("", common_files, router.methods_GET)
			end
end
