var last_regex = "";
var hole = 0;
var score = 0;

$(function() {
	$('#loader').fadeOut(200);
	$('#next').unbind('click');
	$('#new').unbind('click');
	$('#ans').unbind('click');
	$('#regex-input').unbind('keyup');

	$('#regex-input').keyup(function(event) {
		var text = $(event.currentTarget).val();
		if(text != last_regex) {
			$.getJSON('/matches', {'regex':text}, get_matches);
			last_regex = text;
		}
	});
	$('#next').click(function(event) {
		nextRound();
	});
	$('#new').click(function(event) {
		newGame();
	});

	$('#ans').click(function(event) {
		showAnswer();
	});
})

function showAnswer() {
	if($('#ans').hasClass('inactive')) return;

	$('#loader').fadeIn(200);
	$.getJSON('/answer', {}, function(data) {
		$('#regex-input').val(data);
		$.getJSON('/matches', {'regex':data}, get_matches);
		last_regex = data;
		$('#loader').fadeOut(200);
	});
}

function nextRound() {
	if(hole >=18) return;
	$('#match-list').empty();
	$('#reject-list').empty();

	var curr_score = parseInt($('#score').html());
	score += curr_score

	$('#total').html('Score: '+score);
	$('#score').html('0');
	$('#regex-input').val('');

	hole++;
	$('#round').html("Hole: "+hole+" of 18");

	if(hole==18) {
		$('#next').addClass('inactive');
		$('#new').removeClass('inactive');
	}
	load_lists();
}

function newGame() {
	if($('#new').hasClass('inactive')) return;
	$('#match-list').empty();
	$('#reject-list').empty();
	$('#total').html('Score: 0');
	$('#score').html('0');
	$('#regex-input').val('');

	hole=1;
	$('#round').html("Hole: "+hole+" of 18");
	$('.inactive').removeClass('inactive');
	$('#new').addClass('inactive');
	load_lists();
}

function load_lists() {
	$('#loader').fadeIn(200);
	$.getJSON('/lists', {}, function(data) {
		for(var k=0; k<data[0].length; k++) {
			var li1 = $('<li>').html(data[0][k]).css('opacity', '0').addClass('unmatched');
			$('#match-list').append(li1);
		}
		for(var k=0; k<data[1].length; k++) {
			var li2 = $('<li>').html(data[1][k]).css('opacity', '0').addClass('unmatched');
			$('#reject-list').append(li2);
		}
		$('#score').html(data[0].length+'');
		setTimeout(function() {
			$('li').css('opacity', '1');
			$('#loader').fadeOut(200);
		},500);
	});
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