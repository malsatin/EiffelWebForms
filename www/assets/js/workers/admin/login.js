$(function() {

	$('.login-form').on('submit', function(e) {
		e.preventDefault();

		var fd = $('.login-form').serializeArray();

		$.ajax({
			url: apiBaseUrl + 'user-login',
			data: fd,
			success: function(data) {
				generate(data.status, data.msg);

				if(data.status == 'success') {
					Cookies.set('sess_id', data.ssid, {path: '/', expires: 1/12});

					window.location = '/admin/index';
				}
			}
		})
	});

})