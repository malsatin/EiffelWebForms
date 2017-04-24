$(function() {

	$.ajax({
		url: apiBaseUrl + 'get-units',
		success: function(data) {
			if(data.status == 'success') {
				$('.select-unit').empty();

				for(var i = 0; i < data.msg.length; i++) {
					$('.select-unit').append('<option value="' + data.msg[i][0] + '">' + ucfirst(escape(data.msg[i][0])) + '</option>')
				}

				$('.search-btn, .select-unit').prop('disabled', false);
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
		$('.search-btn, .select-unit').prop('disabled', true);

		$.ajax({
			url: apiBaseUrl + 'unit-info',
			data: {
				name: $('.select-unit').val()
			},
			success: function(data) {
				if(data.status == 'success') {
					var unit = data.msg[0];
					var full = JSON.parse(unit[3]);

					$('.unit_name').html(prepare(full.unit_name));
					$('.unit_head').html(prepare(full.unit_head));
					$('.period').html(unit[1] + " - " + unit[2]);
					$('.courses').html(prepare(full.courses));
					$('.exams').html(prepare(full.examinations));
					$('.students_cnt').html(prepare(unit[0]));
				} else {
					generate(data.status, data.msg);
				}
			},
			complete: function() {
				$('.search-btn, .select-unit').prop('disabled', false);
			}
		});
	});
	
})