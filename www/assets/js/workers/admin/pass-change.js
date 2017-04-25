$(function() {

	$('.confirm-btn').on('click', function() {
		var fd = $('.change-password').serializeArray();

		if($('input[name="new_pass"]').val().length == 0) {
			generate("error", "Enter new password");
			return;
		}

		$.ajax({
			url: apiBaseUrl + 'change-pass',
			data: fd,
			success: function(data) {
				generate(data.status, data.msg);

				if(data.status == 'success') {
					$('.change-password input').val(null);
				}
			}
		});
	});

})