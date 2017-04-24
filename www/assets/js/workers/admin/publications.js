$(function() {

	$('.search-btn').on('click', function() {
		$('.search-btn, .selected-year').prop('disabled', true);

		$.ajax({
			url: apiBaseUrl + 'get-publications',
			data: {
				year: Number($('.selected-year').val())
			},
			success: function(data) {
				if(data.status == 'success') {
					var tbody = $('.publications-table tbody');

					if(data.msg.length > 0) {
						tbody.empty();

						var iter = 0;
						for(var i = 0; i < data.msg.length; i++) {
							var unit = data.msg[i][0];
							var pubs = data.msg[i][1].split("\n");
							
							for(var j = 0; j < pubs.length; j++) {
								if(pubs[j].length > 0) {
									tbody.append('<tr><td>' + (++iter) + '</td><td>' + escape(unit) + '</td><td>' + escape(pubs[j]) + '</td></tr>');
								}
							}
						}
					} else {
						tbody.html('<tr><td class="text-center" colspan="3">Nothing found</td></tr>')
					}
				} else {
					generate(data.status, data.msg);
				}
			},
			complete: function() {
				$('.search-btn, .selected-year').prop('disabled', false);
			}
		});
	});

	$('.search-btn').click();

})