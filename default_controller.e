note
	description: "Summary description for {DEFAULT_CONTROLLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	DEFAULT_CONTROLLER

feature
	-- Handlers

	db: SQLITE_DATABASE

feature
	-- Access

	layout: STRING
	content_type: STRING

feature {NONE}
	-- Config

	view_root: STRING = "www/view/"

feature {NONE}
	-- Creation

	make(db_conn: SQLITE_DATABASE)
		require
			db_con_exists: db_conn /= Void
			db_avaliable: NOT db_conn.is_closed AND db_conn.is_accessible
		do
			db := db_conn

			create layout.make_empty
			create content_type.make_empty

			initialize
		end

	initialize
		do
		end

feature
	-- Helpers

	readView(short_path: STRING; custom_root: detachable STRING): STRING
		require
			path_not_void: short_path /= Void
		local
			full_path: PATH
			root_folder: STRING
		do
			if attached custom_root then
				root_folder := custom_root
			else
				root_folder := view_root
			end

			create full_path.make_from_string (root_folder + short_path)

			Result := readFile(getFile(full_path))
		end

	getFile(path: PATH): PLAIN_TEXT_FILE
		require
			path_set: path /= Void AND NOT path.is_empty
		local
			file: PLAIN_TEXT_FILE
			other_path: detachable PATH
		do
			create file.make_with_path (path.absolute_path)

			if NOT file.exists then
				Io.put_string ("ERROR: file not found " + path.out)

				create other_path.make_from_string (view_root + "error/404.html")
				create file.make_with_path (other_path.absolute_path)
			end

			Result := file
		end

	readFile(file: PLAIN_TEXT_FILE): STRING
		do
			--Io.put_string (file.path.absolute_path.out + "%N")
			file.open_read

			from
				Result := ""
			until
				file.end_of_file
			loop
				file.read_line

				Result := Result + file.last_string + "%N "
			end

			file.close
		end

	jsonEncode(data: HASH_TABLE[ANY, STRING]): STRING
		local
			serializer: TABLE_ITERABLE_JSON_SERIALIZER[ANY, STRING]
			context: JSON_SERIALIZER_CONTEXT
		do
			create serializer
			create context.default_create

			Result := serializer.to_json(data, context).representation
		end

feature
	-- Features

	renderHtml(path: STRING; opts: detachable HASH_TABLE[ANY, STRING]): STRING
		require
			path_not_void: path /= Void
		local
			layout_html: STRING
			content_html: STRING
		do
			layout_html := readView("layout/" + layout + ".html", Void)
			content_html := readView(layout + "/" + path + ".html", Void)

			Result := layout_html

			Result.replace_substring_all ("{{insert_content}}", content_html)
		end

	renderJson(data: HASH_TABLE[ANY, STRING]): STRING
		require
			not_void: data /= Void
		do
			Result := jsonEncode(data)
		end

	output(res: WSF_RESPONSE; content: STRING)
		local
			header: HTTP_HEADER
		do
			create header.make

			if content_type ~ "html" then
				header.put_content_type_text_html
			elseif content_type ~ "json" then
				header.put_content_type_text_json
			else
				header.put_content_type_text_plain
			end

			header.put_content_length (content.count)

			res.set_status_code(200)
			res.put_header_lines(header)
			res.put_string(content)
			res.flush
		end

	output404(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			layout_html: STRING
			content_html: STRING
		do
			Io.put_string ("Error 404: " + req.path_info)

			--res.send (create {WSF_NOT_FOUND_RESPONSE}.make (req))
			layout_html := readView("layout/error.html", Void)
			content_html := readView("error/404.html", Void)

			layout_html.replace_substring_all ("{{insert_content}}", content_html)

			output(res, layout_html)
		end

invariant
	content_type /= Void
	layout /= Void

end
