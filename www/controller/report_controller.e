note
	description: "Summary description for {REPORT_CONTROLLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REPORT_CONTROLLER

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
			layout := "report"
			content_type := "html"
		end

feature
	-- Handlers

	handle_main(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
		do
			output(res, renderHtml("index", Void));
		end

	handle_section(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
		do
			if attached {WSF_STRING} req.path_parameter ("number") AS section_id and then section_id.is_integer then
				output(res, renderHtml("section" + section_id.string_representation, Void))
			else
				output404(req, res)
			end
		end

	handle_final(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
		do
			output(res, renderHtml("final", Void));
		end

end
