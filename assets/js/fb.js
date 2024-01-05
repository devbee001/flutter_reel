var lvr = "";
setInterval(function () {
   e = document.querySelector("video"), e && (r = e.currentSrc, e.addEventListener("click", e => {
      lvr != r && (y = document.querySelector("video"), y.pause(), y.currentTime = 0, y.preload = "none", tt = [r], lvr = tt, flutter_inappwebview.callHandler("vidurl", ...tt))
   }))
}, 1);