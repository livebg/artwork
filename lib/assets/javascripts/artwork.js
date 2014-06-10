function getSiteDomain() {
	var hostParts = location.host.toString().split('.');
	for (var i = hostParts.length; i > 2; i--) {
		hostParts.shift();
	}

	return hostParts.join('.');
}

function getDevicePixelRatio() {
	if (typeof window.devicePixelRatio === 'undefined') {
		window.devicePixelRatio = 1.0;
	}

	return window.devicePixelRatio;
}

function shouldLoad2xImages() {
	return getDevicePixelRatio() >= 1.5;
}

function setPixelRatioCookie() {
	$.cookie('_load2ximgs', shouldLoad2xImages() ? 1 : 0, {expires: 365});//, domain: '.' + getSiteDomain()});
}

function getPixelRatioCookie() {
	return $.cookie('_load2ximgs');
}


function setBrowserResolutionCookie() {
	$.cookie('_bSize', $(window).width()+'x'+$(window).height(), {expires: 365});//, domain: '.' + getSiteDomain()});
}

function getBrowserResolutionCookie() {
	return $.cookie('_bSize');
}

function activateResolutionIndependance() {
	$(function () {
		var reload = false;

		if (getPixelRatioCookie() === null) {
			setPixelRatioCookie();
			if (getPixelRatioCookie() !== null && shouldLoad2xImages()) {
				reload = true;
			}
		} else {
			setPixelRatioCookie();
		}
		if(getPixelRatioCookie() === null){
			reload = true;
		}
		setBrowserResolutionCookie();

		if (reload) {
			window.location = window.location;
		}
	});
	$(window).resize(setBrowserResolutionCookie);
}

activateResolutionIndependance();
