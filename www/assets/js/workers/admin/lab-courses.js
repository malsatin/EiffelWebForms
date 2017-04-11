$(function() {

	$.ajax({
		url: apiBaseUrl + 'get-units',
		success: function(data) {
			if(data.status == 'success') {
				$('.select-unit').empty();

				for(var i = 0; i < data.msg.length; i++) {
					$('.select-unit').append('<option value="' + data.msg[i][0] + '">' + ucfirst(data.msg[i][0]) + '</option>')
				}
			} else {
				generate(data.status, data.msg);
			}
		}
	});

	$('.search-btn').on('click', function() {
		var unit = $('.select-unit').val();
		var date_f = $('.date_from').val();
		var date_t = $('.date_to').val();

		if(unit.length == 0 || date_f.length == 0 || date_t.length == 0) {
			generate('error', 'Please, fill all fields');
			return;
		}

		$.ajax({
			url: apiBaseUrl + 'lab-courses',
			data: {
				name: unit,
				from: date_f,
				to: date_t
			},
			success: function(data) {
				if(data.status == 'success') {
					var tbody = $('.courses-table tbody');

					if(data.msg.length > 0) {
						tbody.empty();

						var iter = 0;
						for(var i = 0; i < data.msg.length; i++) {
							var courses = data.msg[i][0].split("\n");
							
							for(var j = 0; j < courses.length; j++) {
								if(courses[j].length > 0) {
									tbody.append('<tr><td>' + (++iter) + '</td><td>' + courses[j] + '</td></tr>');
								}
							}
						}
					} else {
						tbody.html('<tr><td class="text-center" colspan="2">Nothing found</td></tr>')
					}
				} else {
					generate(data.status, data.msg);
				}
			}
		});
	});

})