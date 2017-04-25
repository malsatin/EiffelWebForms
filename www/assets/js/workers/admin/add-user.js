$(function() {

	$('.confirm-btn').on('click', function() {
		var fd = $('.user-create').serializeArray();

		$.ajax({
			url: apiBaseUrl + 'create-user',
			data: fd,
			success: function(data) {
				generate(data.status, data.msg);

				if(data.status == 'success') {
					$('.user-create input').val(null);
				}
			}
		});
	});

});