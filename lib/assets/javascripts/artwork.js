(function () {
  var validity = 365,
      w = window,
      e = document.documentElement,
      domain = location.host.toString().split('.').slice(-2).join('.'),
      isRetina = (window.devicePixelRatio || 1.0) >= 1.5;

  var get = function (name) {
    return (result = new RegExp('(?:^|; )_' + name + '=([^;]*)').exec(document.cookie)) ? result[1] : null;
  }

  var set = function (name, value) {
    var expires = new Date();
    expires.setDate(expires.getDate() + validity);

    document.cookie = [
      '_' + name, '=', String(value),
      '; expires=' + expires.toUTCString(),
      '; domain=' + domain
    ].join('');
  };

  var setSize = function () {
    set('width', w.innerWidth || e.clientWidth);
  };

  var handle = function (e, type, handler) {
    if (e.addEventListener) {
      e.addEventListener(type, handler, false);
    } else if (e.attachEvent) {
      e.attachEvent('on' + type, handler);
    }
  };

  var oldRetina = get('retina'),
      oldWidth  = get('width');

  set('retina', isRetina ? 1 : 0);
  setSize();

  var cookiesWork   = get('retina') !== null,
      retinaChanged = oldRetina !== get('retina'),
      widthChanged  = oldWidth !== get('width');

  if (cookiesWork && (retinaChanged || widthChanged)) {
    window.location.reload(true);
    return;
  }

  handle(w, 'resize', setSize);
})();
