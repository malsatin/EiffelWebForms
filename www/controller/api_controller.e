note
	description: "Summary description for {API_CONTROLLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	API_CONTROLLER

inherit
	DEFAULT_CONTROLLER

create
	make

feature {NONE}
	-- Settings

feature
	-- Handlers

	handle_test (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE[ANY, STRING]
			data: HASH_TABLE[ANY, HASHABLE]
		do
			create resp.make (2)
			data := convertPostData(req)

			resp.put ("success", "status")
			resp.put ("test or testi", "msg")

			output(res, renderJson(resp))
		end

end
