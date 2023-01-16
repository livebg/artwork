(function (window, documentElement) {
  if (window.top != window && !window.useArtworkInFrames) return;

  var cookieValidity = 365,
    cookieDomain = location.host.toString().replace(/:[0-9]+$/, '').split('.').slice(-2).join('.'),
    isRetina = (window.devicePixelRatio || 1.0) >= 1.5;

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

  var isBot = function() {
    var botRegex = "(googlebot\/|Googlebot-Mobile|Googlebot-Image|Google favicon|Mediapartners-Google|bingbot|slurp|java|wget|curl|Commons-HttpClient|Python-urllib|libwww|httpunit|nutch|phpcrawl|msnbot|jyxobot|FAST-WebCrawler|FAST Enterprise Crawler|biglotron|teoma|convera|seekbot|gigablast|exabot|ngbot|ia_archiver|GingerCrawler|webmon |httrack|webcrawler|grub.org|UsineNouvelleCrawler|antibot|netresearchserver|speedy|fluffy|bibnum.bnf|findlink|msrbot|panscient|yacybot|AISearchBot|IOI|ips-agent|tagoobot|MJ12bot|dotbot|woriobot|yanga|buzzbot|mlbot|yandexbot|purebot|Linguee Bot|Voyager|CyberPatrol|voilabot|baiduspider|citeseerxbot|spbot|twengabot|postrank|turnitinbot|scribdbot|page2rss|sitebot|linkdex|Adidxbot|blekkobot|ezooms|dotbot|Mail.RU_Bot|discobot|heritrix|findthatfile|europarchive.org|NerdByNature.Bot|sistrix crawler|ahrefsbot|Aboundex|domaincrawler|wbsearchbot|summify|ccbot|edisterbot|seznambot|ec2linkfinder|gslfbot|aihitbot|intelium_bot|facebookexternalhit|yeti|RetrevoPageAnalyzer|lb-spider|sogou|lssbot|careerbot|wotbox|wocbot|ichiro|DuckDuckBot|lssrocketcrawler|drupact|webcompanycrawler|acoonbot|openindexspider|gnam gnam spider|web-archive-net.com.bot|backlinkcrawler|coccoc|integromedb|content crawler spider|toplistbot|seokicks-robot|it2media-domain-crawler|ip-web-crawler.com|siteexplorer.info|elisabot|proximic|changedetection|blexbot|arabot|WeSEE:Search|niki-bot|CrystalSemanticsBot|rogerbot|360Spider|psbot|InterfaxScanBot|Lipperhey SEO Service|CC Metadata Scaper|g00g1e.net|GrapeshotCrawler|urlappendbot|brainobot|fr-crawler|binlar|SimpleCrawler|Livelapbot|Twitterbot|cXensebot|smtbot|bnf.fr_bot|A6-Indexer|ADmantX|Facebot|Twitterbot|OrangeBot|memorybot|AdvBot|MegaIndex|SemanticScholarBot|ltx71|nerdybot|xovibot|BUbiNG|Qwantify|archive.org_bot|Applebot|TweetmemeBot|crawler4j|findxbot|SemrushBot|yoozBot|lipperhey|y!j-asr|Domain Re-Animator Bot|AddThis)";
    var re = new RegExp(botRegex, 'i');
    var userAgent = navigator.userAgent;
    if (re.test(userAgent)) {
      return true;
    } else {
      return false;
    }
  }

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
    oldWidth = getCookie('width');

  setCookie('retina', isRetina ? 1 : 0);
  setSize();

  var cookiesWork = getCookie('retina') !== null,
    retinaChanged = oldRetina !== getCookie('retina'),
    widthChanged = oldWidth !== getCookie('width');

  if (!isBot() && cookiesWork && (retinaChanged || widthChanged)) {
    if (document.referrer) {
      setCookie('referrer', document.referrer);
    }
    document.documentElement.className += ' artwork-reload-splash';
    window.location.reload(true);
    return;
  }

  addEventHandlerTo(window, 'resize', setSize);
})(window, document.documentElement);
