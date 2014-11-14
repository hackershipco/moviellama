// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap


$(document).ready(function(){
	$( "#runtime" ).slider({ max: 5 , 
		value : $('#runtime').data('value') || 5,
		min: 1,
		step: 0.5,
		slide: function (ev, ui) {
			$('.runtime-value').html(ui.value);
			$('[name="runtime"]').val(ui.value);
		}});
	$( "#imdbmin" ).slider({ max: 10.0 , 
		value : ($('#imdbmin').data('value') >= 0.0 && $('#imdbmin').data('value') !== "") ?  $('#imdbmin').data('value') : 5.0,
		min: 0.0,
		step: 0.5,
		slide: function (ev, ui) {
			$('.imdbmin-value').html(ui.value);
			$('[name="imdbmin"]').val(ui.value);
		}});
	$( "#rtmin" ).slider({ max: 100 , 
		value : ( $('#rtmin').data('value') >= 0 && $('#rtmin').data('value') !== "" ) ?  $('#rtmin').data('value') : 50,
		min: 0,
		step: 5,
		slide: function (ev, ui) {
			$('.rtmin-value').html(ui.value);
			$('[name="rtmin"]').val(ui.value);
		}});


 	
	$(':radio').mousedown(function(e){
  var $self = $(this);
  if( $self.is(':checked') ){
    var uncheck = function(){
      setTimeout(function(){$self.removeAttr('checked');},0);
    };
    var unbind = function(){
      $self.unbind('mouseup',up);
    };
    var up = function(){
      uncheck();
      unbind();
    };
    $self.bind('mouseup',up);
    $self.one('mouseout', unbind);
  }
});


	$('.show-advanced-filters').click(function(){
		$('.show-advanced-filters').hide();
		$('.hide-advanced-filters').css({'display': 'inline-block'});
		$('.advanced-filters').show();

	});

	$('.hide-advanced-filters').click(function(){
		$('.hide-advanced-filters').hide();
		$('.show-advanced-filters').show();
		$('.advanced-filters').hide();
		$('.advanced-filters input, .advanced-filters select').val('');
	});



});



