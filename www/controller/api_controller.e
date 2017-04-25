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
	-- Helpers

	is_date_valid (date: STRING): BOOLEAN
		do
			Result := true
		end

feature
	-- Handlers

	handle_save_report (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			data: HASH_TABLE [ANY, STRING]
			sql_params: HASH_TABLE [ANY, STRING]
			tmp: STRING
			new_id: INTEGER
		do
			create resp.make (2)
			data := convertPostData (req)
			create sql_params.make (10)
			create tmp.make_empty
			if attached data ["unit_name"] as unit_name and
				then attached data ["unit_head"] as unit_head and
				then attached data ["courses"] as courses and
				then attached data ["examinations"] as examinations and
				then attached data ["students_supervised"] as students_supervised and
				then attached data ["students_reports"] as students_reports and
				then attached data ["grants"] as grants and
				then attached data ["projects"] as projects
			then
				tmp := unit_name.out
				tmp.to_lower
				sql_params ["unit_name"] := tmp
				sql_params ["unit_head"] := unit_head.out
				sql_params ["publications"] := ""
				sql_params ["courses"] := courses
				sql_params ["supervised_number"] := (students_supervised.out.occurrences (("%N").at (1)) + 1).out
				sql_params ["collab_number"] := "0"
				sql_params ["patents"] := ""
				sql_params ["students_reports"] := students_reports.out
				sql_params ["all_data"] := jsonEncode (data)
				sql_params ["date_from"] := "2017-01-01"
				sql_params ["date_to"] := "2017-12-31"
				if attached data ["conference_pubs"] as pub1 then
					tmp := tmp + pub1.out
				end
				if attached data ["journal_pubs"] as pub2 then
					tmp := tmp + "%N" + pub2.out
				end
				sql_params ["publications"] := tmp
				if attached data ["research_collab"] as research_collab then
					sql_params ["collab_number"] := (research_collab.out.occurrences (("%N").at (1)) + 1).out
				end
				if attached data ["patents"] as patents then
					sql_params ["patents"] := patents.out
				end
				if attached data ["date_from"] as date_from and then is_date_valid (date_from.out) then
					sql_params ["date_from"] := date_from.out
				end
				if attached data ["date_to"] as date_to and then is_date_valid (date_to.out) then
					sql_params ["date_to"] := date_to.out
				end
				tmp := "[
					INSERT INTO reports (
						unit_name, unit_head, publications, courses, supervised_students_number, research_collaborations_number, patents, students_reports, all_data, date_from, date_to
					) VALUES(
						{{unit_name}}, {{unit_head}}, {{publications}}, {{courses}}, {{supervised_number}}, {{collab_number}}, {{patents}}, {{students_reports}}, {{all_data}}, {{date_from}}, {{date_to}}
					)
				]"
				new_id := db.insert (db.query_escape (tmp, sql_params))
				resp ["status"] := "success"
				resp ["msg"] := "Your report has been saved"
				output (res, renderJson (resp))
			else
				resp ["status"] := "error"
				resp ["msg"] := "One of required fields is not filled"
				output (res, renderJson (resp))
			end
		end

	handle_get_publications (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			data: HASH_TABLE [ANY, STRING]
			sql_params: HASH_TABLE [ANY, STRING]
			db_data: ARRAY [ARRAY [STRING]]
		do
			create resp.make (2)
			data := convertPostData (req)
			create sql_params.make (2)
			if attached data ["year"] as select_year then
				sql_params ["year"] := select_year.out
				sql_params ["next_year"] := (select_year.out.to_integer_32 + 1).out
				db_data := db.select_all (db.query_escape ("SELECT unit_name, publications FROM reports WHERE publications != '' AND date_from >= {{year}} AND date_to <= {{next_year}}", sql_params))
				resp ["status"] := "success"
				resp ["msg"] := db_data
				output (res, renderJson (resp))
			else
				resp ["status"] := "error"
				resp ["msg"] := "Year field is not filled"
				output (res, renderJson (resp))
			end
		end

	handle_get_units (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			db_data: ARRAY [ARRAY [STRING]]
		do
			create resp.make (2)
			db_data := db.select_all ("SELECT unit_name FROM reports WHERE unit_name != '' GROUP BY unit_name")
			resp ["status"] := "success"
			resp ["msg"] := db_data
			output (res, renderJson (resp))
		end

	handle_unit_info (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			data: HASH_TABLE [ANY, STRING]
			sql_params: HASH_TABLE [ANY, STRING]
			db_data: ARRAY [ARRAY [STRING]]
		do
			create resp.make (2)
			data := convertPostData (req)
			create sql_params.make (1)
			if attached data ["name"] as unit then
				sql_params ["u_name"] := unit.out
				db_data := db.select_all (db.query_escape ("SELECT supervised_students_number, date_from, date_to, all_data FROM reports WHERE unit_name = {{u_name}} ORDER BY id DESC LIMIT 1", sql_params))
				resp ["status"] := "success"
				resp ["msg"] := db_data
				output (res, renderJson (resp))
			else
				resp ["status"] := "error"
				resp ["msg"] := "Unit field is not filled"
				output (res, renderJson (resp))
			end
		end

	handle_lab_courses (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			data: HASH_TABLE [ANY, STRING]
			sql_params: HASH_TABLE [ANY, STRING]
			db_data: ARRAY [ARRAY [STRING]]
		do
			create resp.make (2)
			data := convertPostData (req)
			create sql_params.make (3)
			if attached data ["name"] as unit and then attached data ["from"] as d_from and then attached data ["to"] as d_to then
				sql_params ["name"] := unit.out
				sql_params ["from"] := d_from.out
				sql_params ["to"] := d_to.out
				Io.put_string (d_from.out + "%N")
				Io.put_string (d_to.out + "%N")
				db_data := db.select_all (db.query_escape ("SELECT courses FROM reports WHERE unit_name = {{name}} AND courses != '' AND date_from >= {{from}} AND date_to <= {{to}}", sql_params))
				resp ["status"] := "success"
				resp ["msg"] := db_data
				output (res, renderJson (resp))
			else
				resp ["status"] := "error"
				resp ["msg"] := "All fields must be filled"
				output (res, renderJson (resp))
			end
		end

	handle_basic_info (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
		do
			create resp.make (4)
			resp ["status"] := "success"
			resp ["msg"] := "Executed without errors"
			resp ["r_num"] := db.select_row ("SELECT COUNT(*) FROM reports")
			resp ["a_num"] := db.select_row ("SELECT COUNT(*) FROM admins")
			output (res, renderJson (resp))
		end

	handle_students_number (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			db_data: ARRAY [ARRAY [STRING]]
		do
			create resp.make (2)
			db_data := db.select_all ("SELECT unit_name, SUM(supervised_students_number) count FROM reports WHERE unit_name != '' GROUP BY unit_name ORDER BY count DESC")
			resp ["status"] := "success"
			resp ["msg"] := db_data
			output (res, renderJson (resp))
		end

	handle_res_collab_number (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			db_data: ARRAY [ARRAY [STRING]]
		do
			create resp.make (2)
			db_data := db.select_all ("SELECT unit_name, SUM(research_collaborations_number) count FROM reports WHERE unit_name != '' GROUP BY unit_name ORDER BY count DESC")
			resp ["status"] := "success"
			resp ["msg"] := db_data
			output (res, renderJson (resp))
		end

	handle_students_reports (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			data: HASH_TABLE [ANY, STRING]
			sql_params: HASH_TABLE [ANY, STRING]
			db_data: ARRAY [ARRAY [STRING]]
		do
			create resp.make (2)
			data := convertPostData (req)
			create sql_params.make (2)
			if attached data ["year"] as select_year then
				sql_params ["year"] := select_year.out
				sql_params ["next_year"] := (select_year.out.to_integer_32 + 1).out
				db_data := db.select_all (db.query_escape ("SELECT unit_name, students_reports FROM reports WHERE publications != '' AND date_from >= {{year}} AND date_to <= {{next_year}}", sql_params))
				resp ["status"] := "success"
				resp ["msg"] := db_data
				output (res, renderJson (resp))
			else
				resp ["status"] := "error"
				resp ["msg"] := "Year fields is not filled"
				output (res, renderJson (resp))
			end
		end

	handle_unit_patents (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			data: HASH_TABLE [ANY, STRING]
			sql_params: HASH_TABLE [ANY, STRING]
			db_data: ARRAY [ARRAY [STRING]]
		do
			create resp.make (2)
			data := convertPostData (req)
			create sql_params.make (3)
			if attached data ["name"] as unit and then attached data ["from"] as d_from and then attached data ["to"] as d_to then
				sql_params ["name"] := unit.out
				sql_params ["from"] := d_from.out
				sql_params ["to"] := d_to.out
				Io.put_string (d_from.out + "%N")
				Io.put_string (d_to.out + "%N")
				db_data := db.select_all (db.query_escape ("SELECT patents FROM reports WHERE unit_name = {{name}} AND patents != '' AND date_from >= {{from}} AND date_to <= {{to}}", sql_params))
				resp ["status"] := "success"
				resp ["msg"] := db_data
				output (res, renderJson (resp))
			else
				resp ["status"] := "error"
				resp ["msg"] := "All fields must be filled"
				output (res, renderJson (resp))
			end
		end

	handle_create_user (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			resp: HASH_TABLE [ANY, STRING]
			data: HASH_TABLE [ANY, STRING]
			sql_params: HASH_TABLE [ANY, STRING]
			crypt: SHA256
			user_id: INTEGER
		do
			create resp.make (2)
			data := convertPostData (req)
			create sql_params.make (3)

			create crypt.make

			if attached data ["login"] as login and then attached data ["pass"] as pass and then attached data ["pass_2"] as pass_2 then
				sql_params["login"] := login.out

				if login.out.is_empty OR pass.out.is_empty then
					resp ["status"] := "error"
					resp ["msg"] := "You have empty fields"

					output (res, renderJson (resp))
				elseif login.out.count < 5 OR pass.out.count < 7 then
					resp ["status"] := "error"
					resp ["msg"] := "Login or password is too short"

					output (res, renderJson (resp))
				elseif NOT pass.out.same_string(pass_2.out) then
					resp ["status"] := "error"
					resp ["msg"] := "Passwords don't match"

					output (res, renderJson (resp))
				elseif db.select_all (db.query_escape ("SELECT * FROM admins WHERE name = {{login}}", sql_params)).count > 0 then
					resp ["status"] := "error"
					resp ["msg"] := "User already exists"

					output (res, renderJson (resp))
				else
					crypt.update_from_string ("salty" + pass.out + login.out + "sugar")
					sql_params["pass_hash"] := crypt.digest_as_string

					user_id := db.insert (db.query_escape ("INSERT INTO admins (name, password, created) VALUES({{login}}, {{pass_hash}}, datetime('now', 'localtime'))", sql_params))

					if user_id > 0 then
						resp ["status"] := "success"
						resp ["msg"] := "User has been created"
					else
						resp ["status"] := "error"
						resp ["msg"] := "Error in DB"
					end

					output (res, renderJson (resp))
				end
			else
				resp ["status"] := "error"
				resp ["msg"] := "All fields must be filled"
				output (res, renderJson (resp))
			end
		end

end
