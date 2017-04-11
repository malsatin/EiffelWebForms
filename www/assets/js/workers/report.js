$(function() {
	
	var cookieData = Cookies.get('form_data');

	$('.btn-start').on('click', function() {
		window.location = $(this).data('href');
	});

	$('.btn-final').on('click', function() {
		window.location = $(this).data('href');
	});

	$('.btn-prev').on('click', function() {
		window.location = $(this).data('href');
	});

	$('.btn-next').on('click', function() {
		window.location = $(this).data('href');
	});

});