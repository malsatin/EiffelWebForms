$(function() {
	
	var cookieData = Cookies.get('form_control');
	if(typeof cookieData == 'undefined') {
		clearCookie();
	} else {
		cookieData = JSON.parse(cookieData);
	}

	var splitPath = window.location.pathname.split('/');
	var curSection = Number(splitPath.pop());

	if(curSection > cookieData.max_allowed) {
		window.location = '/report/section/1';
	}

	function saveFields() {
		$('.form-control').each(function() {
			var name = this.name;

			if(this.value.trim().length > 0) {
				cookieData.form[name] = this.value.trim();
			}
		});

		updateCookie();
	}

	function updateCookie() {
		Cookies.set('form_control', JSON.stringify(cookieData), {path: '/', expires: 5});
	}

	function clearCookie() {
		cookieData = {
			max_allowed: 1, // section
			form: {} // saved form data
		};
		updateCookie();
	}

	$('.form-control').each(function() {
		var name = this.name;

		if(cookieData.form.hasOwnProperty(name)) {
			this.value = cookieData.form[name].trim();
		}
	});

	$('.form-control').on('focus', function() {
		$(this).closest('.form-group').removeClass('has-error');
	});

	$('.btn-start').on('click', function() {
		clearCookie();

		window.location = $(this).data('href');
	});

	$('.btn-final').on('click', function() {
		var _self = $(this);

		$.ajax({
			url: apiBaseUrl + 'save-report',
			data: cookieData.form,
			success: function(data) {
				if(data.status == 'success') {
					window.location = _self.data('href');
				} else {
					generate(data.status, data.msg);
				}
			}
		});
	});

	$('.btn-prev').on('click', function() {
		var notFilled = $('.form-control[required]').filter(function(ind) {
			return this.value.length == 0;
		});

		if(notFilled.length > 0) {
			cookieData.max_allowed = curSection;
			updateCookie();
		}

		saveFields();

		window.location = $(this).data('href');
	});

	$('.btn-next').on('click', function() {
		saveFields();

		var notFilled = $('.form-control[required]').filter(function(ind) {
			return this.value.length == 0;
		});

		if(notFilled.length > 0) {
			$(notFilled[0]).focus();

			notFilled.closest('.form-group').addClass('has-error');
		} else {
			cookieData.max_allowed = curSection + 1;
			updateCookie();

			window.location = $(this).data('href');
		}
	});

});