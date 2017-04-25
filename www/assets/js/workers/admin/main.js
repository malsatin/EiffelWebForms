$(function() {

	$.ajax({
		url: apiBaseUrl + 'get-units',
		success: function(data) {
			if(data.status == 'success') {
				$('.units_names').empty();

				if(data.msg.length > 0) {
					$('.units_names').append('<ol style="margin-top: 8px"></ol>');

					for(var i = 0; i < data.msg.length; i++) {
						$('.units_names ol').append('<li>' + ucfirst(escape(data.msg[i][0])) + '</li>')
					}
				} else {
					$('.units_names').append('none');
				}
			} else {
				generate(data.status, data.msg);
			}
		}
	});

	$.ajax({
		url: apiBaseUrl + 'get-basic',
		success: function(data) {
			if(data.status == 'success') {

				$('.admins_number').html(Number(data.a_num));
				$('.reports_number').html(Number(data.r_num));
			} else {
				generate(data.status, data.msg);
			}
		}
	});

})