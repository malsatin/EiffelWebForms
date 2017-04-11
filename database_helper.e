note
	description: "Summary description for {DATABASE_HELPER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DATABASE_HELPER

inherit
	SQLITE_DATABASE

create
	my_make

feature
	-- Creation

	my_make(db_file_path: STRING)
		require
			db_file_path /= Void
		do
			open(db_file_path)
		end

	open(db_file_path: STRING)
		do
			make_open_read_write ("stuff/webforms.db")

			if has_error then
				if attached last_exception AS exception then
					Io.put_string ("DB error #" + exception.extended_code.out)
				else
					Io.put_string ("Undefined DB error")
				end
			end
		end

feature
	-- Helpers

	query_escape(sql: STRING; params: HASH_TABLE[ANY, STRING]): STRING
			-- Prevent from SQL-injections
		local
			field: STRING
		do
			create Result.make_from_string (sql)

			across
				params as param
			loop
				field := param.item.out
				field.replace_substring_all ("\", "\\")
				field.replace_substring_all ("'", "''")
				field.replace_substring_all ("%%", "%%%%")

				Result.replace_substring_all ("{{" + param.key + "}}", "'" + field + "'")
			end
		end

	prepare_sql(sql: STRING): STRING
			-- WHY THE HELL ON EARTH DO WE NEED TO ADD SEMICOLONS AT THE END OF THE QUERY????
		do
			Result := sql

			if NOT Result.ends_with (";") then
				Result.append (";")
			end
		end

	select_all(sql: STRING): SQLITE_STATEMENT_ITERATION_CURSOR
		local
			db_query_statement: SQLITE_STATEMENT
			query_result_cursor: SQLITE_STATEMENT_ITERATION_CURSOR
		do
			create db_query_statement.make (prepare_sql(sql), Current)

			query_result_cursor := db_query_statement.execute_new
			query_result_cursor.start

			Result := query_result_cursor
		end

	select_one(sql: STRING): SQLITE_RESULT_ROW
		do
			Result := select_all(sql).item
		end

	insert(sql: STRING): INTEGER
			-- Return inserted row id
		local
			db_insert_statement: SQLITE_INSERT_STATEMENT
		do
			create db_insert_statement.make (prepare_sql(sql), Current)

			db_insert_statement.execute

			Result := db_insert_statement.last_row_id.as_integer_32
		end

	modify(sql: STRING): INTEGER
			-- Return affected rows count. Use both for update and delete queries
		local
			db_modify_statement: SQLITE_MODIFY_STATEMENT
		do
			create db_modify_statement.make (prepare_sql(sql), Current)

			db_modify_statement.execute

			Result := db_modify_statement.changes_count.as_integer_32
		end

end
