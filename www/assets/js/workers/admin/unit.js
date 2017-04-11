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
		if($('.select-unit').val().length == 0) {
			generate('error', 'Please, select the unit');
			return;
		}

		$.ajax({
			url: apiBaseUrl + 'unit-info',
			data: {
				name: $('.select-unit').val()
			},
			success: function(data) {
				if(data.status == 'success') {
					var full = JSON.parse(data.msg[0][3]);

					$('.unit_name').html(full.unit_name);
					$('.unit_head').html(full.unit_head);
					$('.period').html(data.msg[0][1] + " - " + data.msg[0][2]);
					$('.courses').html(full.courses);
					$('.exams').html(full.examinations);
					$('.students_cnt').html(data.msg[0][0]);
				} else {
					generate(data.status, data.msg);
				}
			}
		});
	});
	
})