(function() {
  window.touch_image = function(data, params) {
    var img_src;
    img_src = params["img_src"];
    return $("img[src='" + img_src + "']").attr("src", img_src);
  };

  window.bg_image_error_handling = function(bg_image) {
    if ((bg_image && bg_image.complete && bg_image.naturalWidth === 0) || bg_image && !bg_image.complete) {
      return window.get_ajax("/render_background", {
        filename: bg_image.getAttribute("data-origin")
      }, window.touch_image, {
        img_src: bg_image.getAttribute('src')
      }, true, "GET", "json");
    }
  };

}).call(this);
