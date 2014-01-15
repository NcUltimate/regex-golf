var last_regex = "";

$(function() {
	$('#regex-input').keyup(function(event) {
		var text = $(event.currentTarget).val();
		if(text != last_regex) {
			$.getJSON('/matches', {'regex':text}, get_matches);
			last_regex = text;
		}
	});
	$.getJSON('/lists',load_lists);
})

function load_lists(data) {
	$('#match-list').empty();
	$('#reject-list').empty();
	$('#max-score').html('/ 200');
	for(var k=0; k<20; k++) {
		var li1 = $('<li>').html(data[0][k]).css('opacity', '0');
		var li2 = $('<li>').html(data[1][k]).css('opacity', '0');
		$('#match-list').append(li1);
		$('#reject-list').append(li2);
	}
	setTimeout(function() {
		$('li').css('opacity', '1');
		$('#loader').fadeOut(200);
	},500);
	$('#max-score').html('/ ' + data[2]);
}

function get_matches(data) {
	$('li').removeClass('matched');
	$('li').addClass('unmatched');
	var matches = $('#match-list li');
	var rejects = $('#reject-list li');
	for(var idx in data[0]) {
		for(var k=0; k<matches.length; k++) {
			if(data[0][idx] == $(matches[k]).html()) {
				$(matches[k]).removeClass('unmatched');
				$(matches[k]).addClass('matched');
				break;
			}
		}
	}
	for(var idx in data[1]) {
		for(var k=0; k<rejects.length; k++) {
			if(data[1][idx] == $(rejects[k]).html()) {
				$(rejects[k]).removeClass('unmatched');
				$(rejects[k]).addClass('matched');
				break;
			}
		}
	}
	$('#score').html(data[2]);
}