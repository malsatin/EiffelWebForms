$(function() {

	$('.login-btn').on('click', function() {
		var fd = $('.login-form').serializeArray();

		$.ajax({
			url: apiBaseUrl + 'user-login',
			data: fd,
			success: function(data) {
				generate(data.status, data.msg);
			}
		})
	});

})