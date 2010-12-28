var toolTips = new Tips('[title]', {
  offset: { x:-8, y:16 }
});

if (window.orientation) {
  var setOrientation = function() {
    var orient = Math.abs(window.orientation) === 90 ? 'landscape' : 'portrait';
    var cl = document.body.className;  
    cl = cl.replace(/portrait|landscape/, orient);  
    document.body.className = cl;  
  }
  window.addEventListener('load', setOrientation, false);  
  window.addEventListener('orientationchange', setOrientation, false);
}

window.addEventListener('load', function(){
  setTimeout(scrollTo, 0, 0, 1);
}, false);