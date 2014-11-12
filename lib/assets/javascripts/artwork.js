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
      '; domain=' + cookieDomain,
      '; path=/'
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
    document.documentElement.className += ' artwork-reload-splash';

    var css = 'html.artwork-reload-splash body { display: none; }',
        head = document.head || document.getElementsByTagName('head')[0], /* IE8 has no document.head.. FIXME remove when IE8 is not supported */
        style = document.createElement('style');

    style.type = 'text/css';
    if (style.styleSheet) {
      style.styleSheet.cssText = css;
    } else {
      style.appendChild(document.createTextNode(css));
    }

    head.appendChild(style);

    window.location.reload(true);
    return;
  }

  addEventHandlerTo(window, 'resize', setSize);
})(window, document.documentElement);
