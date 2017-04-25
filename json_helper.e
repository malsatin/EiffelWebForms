note
	description: "Summary description for {JSON_HELPER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_HELPER

	inherit
		ANY

create
	default_create

feature

	encode(data: HASH_TABLE[ANY, HASHABLE]): STRING
		local
			serializer: JSON_HASH_TABLE_CONVERTER
		do
			create serializer.make
			create Result.make_empty

			if attached serializer.to_json(data) as converted then
				Result := converted.representation
			else
				Result := "{%"status%": %"error%", %"msg%": %"JSON serialization error%"}"
			end
		ensure
			Result /= Void
		end

	decode(data: STRING): HASH_TABLE[ANY, HASHABLE]
		local
			serializer: JSON_HASH_TABLE_CONVERTER
			tmp: JSON_OBJECT
		do
			create serializer.make
			create tmp.make
			tmp.put_string ("str", data)

			if attached serializer.from_json (tmp) as converted then
				Result := converted
			else
				create Result.make (2)
				Result["status"] := "error"
				Result["msg"] := "Deserialization error"
			end
		end

end
