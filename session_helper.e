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
			removed_count: INTEGER
		do
			removed_count := db.modify ("DELETE FROM sessions WHERE update_time < datetime('now', 'localtime', '-2 hour')")
			Io.put_string ("Cleaned " + removed_count.out + " sessions rows")
			Io.new_line
		end

	extend_current(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			params: HASH_TABLE[STRING, STRING]
			data: ARRAY[ARRAY[STRING]]
			cookie: WSF_COOKIE
			datet: DATE_TIME
			dtd: DATE_TIME_DURATION
		do
			create params.make (1)

			if attached req.cookie ("sess_id") as sess_id then
				params["sess_id"] := sess_id.as_string.string_representation

				data := db.select_all (db.query_escape ("SELECT * FROM sessions WHERE id = {{sess_id}}", params))

				if data.count > 0 then
					create datet.make_now
					create dtd.make(0, 0, 0, 2, 0, 0)
					datet.add (dtd)

					create cookie.make ("sess_id", sess_id.as_string.string_representation)
					cookie.set_path ("/")
					cookie.set_expiration_date(datet)

					db.just_modify (db.query_escape ("UPDATE sessions SET update_time = datetime('now', 'localtime') WHERE id = {{sess_id}}", params))
				else
					Io.put_string ("Removing current session")
					Io.new_line

					create datet.make_now
					create dtd.make(-1, 0, 0, 0, 0, 0)
					datet.add (dtd)

					create cookie.make ("sess_id", "__remove__")
					cookie.set_path ("/")
					cookie.set_expiration_date(datet)
				end

				res.add_cookie (cookie)
			end
		end

feature
	-- Public

	start(name: STRING): STRING
		local
			rand: V_RANDOM
			crypt: MD5
			sid: STRING
		do
			create rand.default_create
			create crypt.make

			check_db

			from
				crypt.update_from_string (name + rand.long_item.out)
				sid := crypt.digest_as_string
			until
				db.select_all ("SELECT * FROM sessions WHERE id = '" + sid + "'").count = 0
			loop
				crypt.update_from_string (name + rand.long_item.out)
				sid := crypt.digest_as_string
			end

			db.just_insert ("INSERT INTO sessions (id, data, update_time) VALUES('" + sid + "', '" + name + "', datetime('now', 'localtime'))")

			Result := sid
		end

	get(req: WSF_REQUEST; res: WSF_RESPONSE): detachable STRING
		local
			params: HASH_TABLE[STRING, STRING]
			data: ARRAY[ARRAY[STRING]]
		do
			Result := Void
			check_db

			if attached req.cookie ("sess_id") as sess_id then
				extend_current (req, res)

				create params.make (1)
				params["sess_id"] := sess_id.as_string.string_representation

				data := db.select_all (db.query_escape ("SELECT data FROM sessions WHERE id = {{sess_id}}", params))

				if data.count > 0 then
					extend_current (req, res)

					Result := data.at (1).at (1)
				end
			end
		end

	destroy(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			params: HASH_TABLE[STRING, STRING]
			datet: DATE_TIME
			dtd: DATE_TIME_DURATION
			cookie: WSF_COOKIE
		do
			check_db

			if attached req.cookie ("sess_id") as sess_id then
				create params.make (1)
				params["sess_id"] := sess_id.as_string.string_representation

				db.just_modify (db.query_escape ("DELETE FROM sessions WHERE id = {{sess_id}}", params))

				create datet.make_now
				create dtd.make(0, 0, 0, -2, 0, 0)
				datet.add (dtd)

				create cookie.make ("sess_id", "")
				cookie.set_path ("/")
				cookie.set_expiration_date(datet)
			end
		end


	is_logged_in(req: WSF_REQUEST; res: WSF_RESPONSE): BOOLEAN
		local
			params: HASH_TABLE[STRING, STRING]
		do
			Result := false
			check_db

			create params.make (1)

			if attached req.cookie ("sess_id") as sess_id then
				params["sess_id"] := sess_id.as_string.string_representation

				Io.put_string (db.query_escape ("SELECT * FROM sessions WHERE id = {{sess_id}}", params))
				if db.select_all (db.query_escape ("SELECT * FROM sessions WHERE id = {{sess_id}}", params)).count > 0 then
					extend_current (req, res)

					Result := true
				end
			end
		end

end
