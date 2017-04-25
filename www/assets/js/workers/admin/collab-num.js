$(function() {
	
	$.ajax({
		url: apiBaseUrl + 'res-collab-number',
		success: function(data) {
			if(data.status == 'success') {
				var tbody = $('.courses-table tbody');

				if(data.msg.length > 0) {
					tbody.empty();

					var iter = 0;
					for(var i = 0; i < data.msg.length; i++) {
						tbody.append('<tr><td>' + (i + 1) + '</td><td>' + escape(data.msg[i][0]) + '</td><td>' + Number(data.msg[i][1]) + '</td></tr>');
					}
				} else {
					tbody.html('<tr><td class="text-center" colspan="3">Nothing found</td></tr>')
				}
			} else {
				generate(data.status, data.msg);
			}
		}
	});

})