note
	description: "Summary description for {API_CONTROLLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	API_CONTROLLER

inherit
	DEFAULT_CONTROLLER
	redefine
		initialize
	end

create
	make

feature {NONE}
	-- Settings

	initialize
		do
			content_type := "json"
		end

feature
	-- Handlers

	handle_test (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE[ANY, STRING]
			data: HASH_TABLE[ANY, STRING]
			query_params: HASH_TABLE [ANY, STRING]
			new_id: INTEGER
		do
			create resp.make (2)
			data := convertPostData(req)

			create query_params.make (2)

			if NOT (data.has ("name") OR data.has ("pass")) then
				resp["status"] := "error"
				resp["msg"] := "lack of params"

				output(res, renderJson(resp))
			else
				if attached data.at ("name") AS name then
					query_params["admin_name"] := name.out
				end
				if attached data.at ("pass") AS pass then
					query_params["admin_pass"] := pass.out
				end

				new_id := db.insert (db.query_escape ("INSERT INTO admins (name, password) VALUES({{admin_name}}, {{admin_pass}})", query_params))

				resp["status"] := "success"
				resp["msg"] := "user added"
				output(res, renderJson(resp))
			end
		end

end
