'use strict';
(function($) {
	// global namespace
    window.APP_ASSOCIATED_MATERIALS = {
        staticResourcePath: ''
    }
    
    $('input[id$=submit]').on('click', function() {
    	$('input[id$=communityNickname]').val(Math.random().toString(36).slice(2).toString().substring(0, 38));
    });
    
    $('input[id$=password]').attr('required', true);
    
    $(document).ready(function() {
    	// dynamically assign company logo
    	// alpine
    	if(window.location.href.match(/alpine/)) {
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathAlpine+') no-repeat fixed').css('background-size', 'cover');
    		window.localStorage.setItem('brand', 'alpine');
    		$('[id$=origin]').val('alpine');
    	}else if(window.localStorage.getItem('brand')==='alpine') {
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathAlpine+') no-repeat fixed').css('background-size', 'cover');
    		window.localStorage.setItem('brand', 'alpine');
    		$('[id$=origin]').val('alpine');
    	}
    	// gentek
    	if(window.location.href.match(/gentek/)) {
    		window.localStorage.setItem('brand', 'gentek');
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathGentek+') no-repeat fixed').css('background-size', 'cover');
    		$('[id$=origin]').val('gentek');
    	}else if(window.localStorage.getItem('brand')==='gentek') {
    		window.localStorage.setItem('brand', 'gentek');
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathGentek+') no-repeat fixed').css('background-size', 'cover');
    		$('[id$=origin]').val('gentek');
    	}
    	// revere
    	if(window.location.href.match(/revere/)) {
    		window.localStorage.setItem('brand', 'revere');
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathRevere+') no-repeat fixed').css('background-size', 'cover');
    		$('[id$=origin]').val('revere');
    	}else if(window.localStorage.getItem('brand')==='revere') {
    		window.localStorage.setItem('brand', 'revere');
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathRevere+') no-repeat fixed').css('background-size', 'cover');
    		$('[id$=origin]').val('revere');
    	}
    	// alside
    	if(window.location.href.match(/alside/)) {
    		window.localStorage.setItem('brand', 'alside');
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathAlside+') no-repeat fixed').css('background-size', 'cover');
    		$('[id$=origin]').val('alside');
    	}else if(window.localStorage.getItem('brand')==='alside') {
    		window.localStorage.setItem('brand', 'alside');
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathAlside+') no-repeat fixed').css('background-size', 'cover');
    		$('[id$=origin]').val('alside');
    	}
    	// preservation
    	if(window.location.href.match(/preservation/)) {
    		window.localStorage.setItem('brand', 'preservation');
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathPreservation+') no-repeat fixed').css('background-size', 'cover');
    		$('[id$=origin]').val('preservation');
    	}else if(window.localStorage.getItem('brand')==='preservation') {
    		window.localStorage.setItem('brand', 'preservation');
    		$('html').css('background', 'url('+APP_ASSOCIATED_MATERIALS.staticResourcePathPreservation+') no-repeat fixed').css('background-size', 'cover');
    		$('[id$=origin]').val('preservation');
    	}
    });
}(jQuery));