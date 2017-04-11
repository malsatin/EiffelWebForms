var apiBaseUrl = '/api/';

function generate(type, message, options) {
	var opt = {
		text        : message,
		type        : type,
		dismissQueue: true,
		timeout     : 10000,
		closeWith   : ['click', 'button'],
		layout      : 'topRight',
		theme       : 'bootstrapTheme',
		/*progressBar : true, // Works only in 2.4.0+*/
		maxVisible  : 7,
		animation: {
			open: {height: 'toggle'},
			close: {height: 'toggle'},
			easing: 'swing',
			speed: 350
		}
	};

	if(options) {
		$.each(options, function(index, value) {
			opt[index] = value;
		});
	}

	var n = noty(opt);
	
	return n.options.id;
}

function ucfirst(str) {
	var f = str.charAt(0).toUpperCase();

	return f + str.substr(1, str.length-1);
}

/*function noty_test() {
	generate('alert', 'alert');
	generate('success', '<b>success</b>');
	generate('warning', 'warning');
	generate('error', 'error');
	generate('information', 'information');
	generate('', 'Do you want to continue?', {
		buttons: [
			{
				addClass: 'btn btn-primary btn-sm',
				text: 'Ok',
				onClick: function($noty) {
					// this = button element
					// $noty = $noty element

					console.log($noty.$bar.find('input#example').val());

					$noty.close();
					generate('success', 'You clicked "Ok" button');
				}
			},
			{
				addClass: 'btn btn-danger',
				text: 'Cancel',
				onClick: function($noty) {
					$noty.close();
					generate('error', 'You clicked "Cancel" button');
				}
			}
		]
	});
}*/

$(function() {
	$.ajaxSetup({
		type: 'POST',
		dataType: 'json',
		success: function(data) {
			if(data.msg) {
				generate(data.status, data.msg);
			}
		},
		error: function() {
			generate("error", "Can't connect with server");
		}
	});
});