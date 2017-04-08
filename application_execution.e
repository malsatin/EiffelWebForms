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

				map_uri_agent("/", agent handle_main, router.methods_GET);
			end

	handle_main (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			pg: WSF_PAGE_RESPONSE
		do
			create pg.make_with_body (req.path_info)
			
			res.send (pg)
		end

end
