function declineCountable(num, arr) {
    num = Math.abs(Number(num) % 100);
    if(num > 19)
        num %= 10;
    
    if(num == 1)
        return arr[0];
    if(num > 1 && num < 5)
        return arr[1];
    return arr[2];
}

function generate(type, message, options) {
    var opt = {
        text        : message,
        type        : type,
        dismissQueue: true,
        timeout     : 10000,
        closeWith   : ['click'/*, 'button'*/],
        layout      : 'topRight',
        theme       : 'bootstrapTheme',
        //progressBar : true, // Works only in 2.4.0+
        maxVisible  : 7,
        animation: {
            open: {height: 'toggle'},
            close: {height: 'toggle'},
            easing: 'swing',
            speed: 350
        },
    };

    if(options) {
        $.each(options, function(index, value) {
            opt[index] = value;
        });
    }

    var n = noty(opt);

    //console.log('html: ' + n.options.id);
    return n.options.id;
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

var apiBaseUrl = '/api/';

$.ajaxSetup({
    type: 'POST',
    dataType: 'json'
})
.fail(function() {
    generate("error", "Can't connect with server");
});
