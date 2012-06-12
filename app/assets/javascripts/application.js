// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .

$(function(){
	$('#nav_update').hover(
		function(){
			$('#nav_update .icon-time').addClass('icon-refresh')
		},
		function(){
			$('#nav_update .icon-time').removeClass('icon-refresh')
		}
	);
	
	var interval = 300
	
	reload_page = function(){
		$('#nav_update .icon-time').removeClass('icon-exclamation-sign')
		$('#nav_update .icon-time').addClass('icon-refresh')	
		$.ajax({
		  url: '/alive',
		  success: function(data) {
				window.location.reload();
		  },
			error: function(data) {
				$('#nav_update').removeClass('badge-info')
				$('#nav_update').removeClass('badge-success')
				$('#nav_update').addClass('badge-warning')
		    $('#nav_update .icon-time').removeClass('icon-refresh')
				$('#nav_update .icon-time').addClass('icon-exclamation-sign')
				update_countdown(10);	
		  }
		});	
	};
	
	update_countdown = function(timeleft){
		if(timeleft >= 0){
			minutes = Math.floor(timeleft/60);
			seconds = timeleft % 60;
			if (seconds < 10) {
				seconds = '0' + seconds
			}
			$('#countdown').html(minutes + ':' + seconds)
			setTimeout('update_countdown('+(timeleft - 1)+')','1000');
		}
		if (timeleft == 0) {
			$('#nav_update').addClass('badge-info')
			reload_page();
		}
		timeleft = timeleft - 1
	};
	
	if ($('#countdown')){
		update_countdown(interval);		
	}
		
});
