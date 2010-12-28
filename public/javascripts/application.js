var toolTips = new Tips('[title]', {
  offset: { x:-8, y:16 }
});

if (Browser.Platform.ios) {
  if (hw = /(ip(?:ad|od|hone))/.exec(navigator.userAgent.toLowerCase())) {
    Browser.Platform.hardware = hw[1];
    Browser.Platform[Browser.Platform.hardware] = true;
  }

  window.addEventListener('load', function(){
    setTimeout(scrollTo, 0, 0, 1);
  }, false);

  var setOrientation = function() {
    var orient = Math.abs(window.orientation) === 90 ? 'landscape' : 'portrait';
    var cl = document.body.className;  
    cl = cl.replace(/portrait|landscape/, orient);  
    document.body.className = cl;  
  }
  window.addEventListener('load', setOrientation, false);  
  window.addEventListener('orientationchange', setOrientation, false);
}
