note
	description: "Summary description for {ADMIN_CONTROLLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ADMIN_CONTROLLER

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
			layout := "admin"
			content_type := "html"
		end

feature
	-- Handlers

	handle_page (req: WSF_REQUEST; res: WSF_RESPONSE)
		do
			if attached {WSF_STRING} req.path_parameter ("page") AS page and then not page.is_empty then
				output (res, renderHtml (page.string_representation, Void))
			else
				output404 (req, res)
			end
		end

	handle_login (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			defaultLayout: detachable STRING
		do
			defaultLayout := layout
			layout := "report"
			output (res, renderHtml ("login", Void))
			layout := defaultLayout
		end

end
