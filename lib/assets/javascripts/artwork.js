var Artwork = function () {
	var self = this;

	self.getSiteDomain = function () {
		var hostParts = location.host.toString().split('.');
		return hostParts.slice(hostParts.length - 2, hostParts.length).join('.');
	}

	self.getDevicePixelRatio = function () {
		if (typeof window.devicePixelRatio === 'undefined') {
			window.devicePixelRatio = 1.0;
		}

		return window.devicePixelRatio;
	}

	self.shouldLoad2xImages = function () {
		return self.getDevicePixelRatio() >= 1.5;
	}

	self.getPixelRatioCookie = function () {
		return $.cookie('_load2ximgs');
	}

	self.getBrowserResolutionCookie = function () {
		return $.cookie('_bSize');
	}

	self.setPixelRatioCookie = function () {
		var retinaFlag = self.shouldLoad2xImages() ? 1 : 0;
		$.cookie('_load2ximgs', retinaFlag, {expires: 365, domain: '.' + self.getSiteDomain()});
	}

	self.setBrowserResolutionCookie = function () {
		var windowSize = $(window).width() + 'x' + $(window).height();
		$.cookie('_bSize', windowSize, {expires: 365, domain: '.' + self.getSiteDomain()});
	}

	self.activateResolutionIndependance = function () {
		var oldPixelRatioCookie        = self.getPixelRatioCookie();
		var oldBrowserResolutionCookie = self.getBrowserResolutionCookie();

		self.setPixelRatioCookie();
		self.setBrowserResolutionCookie();

		var cookiesWork              = self.getPixelRatioCookie() !== null && self.getBrowserResolutionCookie() !== null;
		var pixelRatioChanged        = oldPixelRatioCookie !== self.getPixelRatioCookie();
		var browserResolutionChanged = oldBrowserResolutionCookie !== self.getBrowserResolutionCookie();

		if (cookiesWork && (pixelRatioChanged || browserResolutionChanged)) {
			// Force reload without using the cache
			window.location.reload(true);
			return;
		}

		$(window).resize(self.setBrowserResolutionCookie);
	}

	self.activateResolutionIndependance();
};

Artwork.instance = new Artwork();
