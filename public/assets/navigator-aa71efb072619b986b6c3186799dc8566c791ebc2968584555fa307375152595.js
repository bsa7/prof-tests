(function() {
  var document_onclick;

  window.history_pushState = function(page_url, document_title) {
    page_url = page_url.replace(/#+$/, '');
    return history.pushState({
      page: page_url,
      type: "page"
    }, document_title, page_url);
  };

  window.onpopstate = function(e) {
    var page_cache;
    page_cache = null;
    if (e.state && e.state.page) {
      page_cache = window.read_page_cache(e.state.page);
      window.history_pushState(e.state.page, document.title);
    }
    if (page_cache && page_cache.value) {
      return window.receive_and_draw_page(page_cache.value, {
        page: e.state.page
      });
    } else if (e.state && e.state.page) {
      return window.update_page_cache(e.state.page);
    } else {
      return window.update_page_cache(window.current_location());
    }
  };

  window.read_page_cache = function(key) {
    var cache;
    return cache = window.varCache("pg#" + key);
  };

  window.save_page_cache = function(key, value) {
    return window.varCache("pg#" + key, value);
  };

  window.receive_and_draw_page = function(data, params) {
    var jquery_while_loading;
    if (data) {
      window.save_page_cache(params.page, data.html || data);
      window.history_pushState(params.page, document.title);
      $(window.content_selector).html(data.html || data);
      $(document).scrollTop(0, 0);
      if (window.get_page_sign() === "front") {
        window.front_doc_ready();
      } else if (window.get_page_sign() === "back") {
        window.back_doc_ready();
      }
      window.set_on_change_listenter();
      jquery_while_loading = $("." + window.while_loading_class);
      if (jquery_while_loading.length > 0) {
        return jquery_while_loading.addClass(window.invisible_class);
      }
    }
  };

  window.update_page_cache = function(page) {
    var jquery_while_loading;
    window.get_ajax(page, {
      format: "html",
      layout: false,
      ajaxLoad: true
    }, window.receive_and_draw_page, {
      page: page
    }, true, "GET", "html");
    jquery_while_loading = $("." + window.while_loading_class);
    if (jquery_while_loading.length > 0) {
      return jquery_while_loading.removeClass(window.invisible_class);
    }
  };

  window.set_page = function(page) {
    var cache;
    cache = window.read_page_cache(page);
    if (cache && cache.value) {
      window.receive_and_draw_page(cache.value, {
        page: page
      });
      if (window.current_timestamp() - cache.t > window.default_page_live_time) {
        return window.update_page_cache(page);
      }
    } else {
      return window.update_page_cache(page);
    }
  };

  $(document).click(function(e) {
    return document_onclick(e);
  });

  document_onclick = function(e) {
    if (/^[aA]$/.test(e.target.tagName) && /^\//.test(e.target.getAttribute("href")) && !e.target.hasAttribute("data-ajax")) {
      e.preventDefault();
      return window.set_page($(e.target).attr("href"));
    }
  };

}).call(this);
