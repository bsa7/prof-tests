(function() {
  window.status_body = function(status, html, seconds) {
    var color_by_status, snackbar_html, state;
    if (seconds == null) {
      seconds = null;
    }
    color_by_status = {
      error: "crimson",
      success: "forestgreen",
      info: "navy"
    };
    if (seconds && seconds > 0) {
      seconds = seconds * 1000;
      state = "on-time";
    } else {
      state = "static";
    }
    snackbar_html = HandlebarsTemplates['system_navigation_bar']({
      bgcolor: color_by_status[status],
      html: html,
      state: state
    });
    $("#snackbar").remove();
    $("body").append(snackbar_html);
    if (seconds && seconds > 0) {
      $("#snackbar > .data-transparent").animate({
        opacity: 0,
        WebkitTransition: "opacity 2s ease-in-elastic",
        MozTransition: "opacity 2s ease-in-elastic",
        MsTransition: "opacity 2s ease-in-elastic",
        OTransition: "opacity 2s ease-in-elastic",
        transition: "opacity 2s ease-in-elastic"
      }, seconds, function() {});
      return $("#snackbar > div.data-message").animate({
        opacity: 0
      }, seconds, function() {
        return $("#snackbar").remove();
      });
    }
  };

  $(document).click(function(e) {
    var id;
    id = window.get_attr(e.target, "id", 3);
    if (/snackbar/.test(id)) {
      return $("#snackbar").remove();
    }
  });

  window.close_status = function() {
    return $("#snackbar.static").remove();
  };

}).call(this);
