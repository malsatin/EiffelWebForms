note
	description: "Summary description for {SESSION_HELPER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SESSION_HELPER

create
	make

feature
	-- Handlers

	db: DATABASE_HELPER
	json: JSON_HELPER

feature {NONE}

	make(db_conn: DATABASE_HELPER)
		do
			db := db_conn
			create json.default_create
		end

feature
	-- DB cleaner

	check_db
		local
			tmp: INTEGER
		do
			tmp := db.modify ("DELETE FROM sessions WHERE update_time < datetime('now', '-2 hours')")
		end

	extend_current(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			params: HASH_TABLE[STRING, STRING]
			data: ARRAY[ARRAY[STRING]]
			cookie: WSF_COOKIE
			datet: DATE_TIME
			dtd: DATE_TIME_DURATION
			tmp: INTEGER
		do
			create params.make (1)

			if attached req.cookie ("sess_id") as sess_id then
				params["sess_id"] := sess_id.out

				data := db.select_all (db.query_escape ("SELECT * FROM sessions WHERE id = {{sess_id}}", params))

				if data.count > 0 then
					create datet.make_now
					create dtd.make(0, 0, 0, 2, 0, 0)
					datet.add (dtd)

					create cookie.make ("sess_id", sess_id.out)
					cookie.set_path ("/")
					cookie.set_expiration_date(datet)

					tmp := db.modify (db.query_escape ("UPDATE sessions SET update_time = datetime('now', 'localtime') WHERE id = {{sess_id}}", params))
				else
					create datet.make_now
					create dtd.make(0, 0, 0, -2, 0, 0)
					datet.add (dtd)

					create cookie.make ("sess_id", sess_id.out)
					cookie.set_path ("/")
					cookie.set_expiration_date(datet)
				end

				res.add_cookie (cookie)
			end
		end

feature
	-- Public

	get(req: WSF_REQUEST): detachable HASH_TABLE[ANY, HASHABLE]
		local
			params: HASH_TABLE[STRING, STRING]
			data: ARRAY[ARRAY[STRING]]
		do
			Result := Void

			create params.make (1)

			if attached req.cookie ("sess_id") as sess_id then
				params["sess_id"] := sess_id.out

				data := db.select_all (db.query_escape ("SELECT * FROM sessions WHERE id = {{sess_id}}", params))

				if data.count > 0 then
					Result := json.decode(data.at (1).at (1))
				else
				end
			end
		end

	is_logged_in(req: WSF_REQUEST): BOOLEAN
		local
			params: HASH_TABLE[STRING, STRING]
		do
			Result := false
			check_db

			create params.make (1)

			if attached req.cookie ("sess_id") as sess_id then
				params["sess_id"] := sess_id.out

				Io.put_string (db.query_escape ("SELECT * FROM sessions WHERE id = {{sess_id}}", params))
				if db.select_all (db.query_escape ("SELECT * FROM sessions WHERE id = {{sess_id}}", params)).count > 0 then
					Result := true
				end
			end
		end

end
