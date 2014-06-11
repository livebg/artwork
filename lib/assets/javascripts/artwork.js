(function (window, documentElement) {
  var cookieValidity = 365,
      cookieDomain   = location.host.toString().split('.').slice(-2).join('.'),
      isRetina       = (window.devicePixelRatio || 1.0) >= 1.5;

  var getCookie = function (name) {
    return (result = new RegExp('(?:^|; )_' + name + '=([^;]*)').exec(document.cookie)) ? result[1] : null;
  }

  var setCookie = function (name, value) {
    var expires = new Date();
    expires.setDate(expires.getDate() + cookieValidity);

    document.cookie = [
      '_' + name, '=', String(value),
      '; expires=' + expires.toUTCString(),
      '; domain=' + cookieDomain
    ].join('');
  };

  var setSize = function () {
    setCookie('width', window.innerWidth || documentElement.clientWidth);
  };

  var addEventHandlerTo = function (element, type, handler) {
    if (element.addEventListener) {
      element.addEventListener(type, handler, false);
    } else if (element.attachEvent) {
      element.attachEvent('on' + type, handler);
    }
  };

  var oldRetina = getCookie('retina'),
      oldWidth  = getCookie('width');

  setCookie('retina', isRetina ? 1 : 0);
  setSize();

  var cookiesWork   = getCookie('retina') !== null,
      retinaChanged = oldRetina !== getCookie('retina'),
      widthChanged  = oldWidth !== getCookie('width');

  if (cookiesWork && (retinaChanged || widthChanged)) {
    window.location.reload(true);
    return;
  }

  addEventHandlerTo(window, 'resize', setSize);
})(window, document.documentElement);
