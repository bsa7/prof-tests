(function() {
  'use strict';
  var index_from_str, on_field_change, set_avatar;

  window.cache = {};

  window.set_on_change_listenter = function() {
    var element_selector, form_elements, j, len, results;
    form_elements = ["input", "select", "textarea"];
    results = [];
    for (j = 0, len = form_elements.length; j < len; j++) {
      element_selector = form_elements[j];
      if ($(element_selector).length > 0) {
        results.push($(element_selector).on({
          blur: function() {
            return on_field_change(this.id);
          },
          change: function() {
            return on_field_change(this.id);
          }
        }));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  on_field_change = function(id) {
    if (window.get_page_sign() === window.frontend_sign) {
      window.store_form_values();
      window.update_specialization_index(10, true);
      window.on_main_performer_price_change(id);
      return window.on_specialization_change(id);
    }
  };

  window.on_specialization_change = function(id) {
    if ($(window.performers_filter_selector).length === 0) {
      return;
    }
    if (("select#" + id) === window.search_by_specialization_selector && window.current_location() !== "/") {
      return window.history_pushState($("select#" + id).val());
    }
  };

  window.on_main_performer_price_change = function(id) {
    var jquery_commission_summ, jquery_main_performer_price, main_performer_price_attr;
    main_performer_price_attr = "main-performer-price";
    if (new RegExp(main_performer_price_attr).test(id)) {
      jquery_main_performer_price = $("#" + main_performer_price_attr);
      jquery_commission_summ = $("#commission-summ");
      if (jquery_main_performer_price.length > 0) {
        if (jquery_main_performer_price.val() > 20000) {
          jquery_commission_summ.val(10000);
        } else {
          jquery_commission_summ.val(5000);
        }
        return $("#total-performer-cost").val(parseInt(jquery_main_performer_price.val()) + parseInt(jquery_commission_summ.val()));
      }
    }
  };

  window.datetime_picker_initialize = function() {
    if ($(window.date_class_selector).length > 0) {
      return $(window.date_class_selector).pickmeup({
        change: window.date_picker_change
      });
    }
  };

  window.varCache = function(key, value) {
    var cache_value, e, error, error1, res, stored_json, timestamp, value_json;
    res = null;
    if (typeof window.localStorage !== "undefined") {
      if (key && value) {
        timestamp = window.current_timestamp();
        try {
          if (/^pg#/.test(key)) {
            cache_value = {
              v: LZString.compressToUTF16(value.replace(/(?:\\[rn]|[\r\n]+)+/g, "")),
              t: timestamp
            };
          } else {
            cache_value = {
              v: value,
              t: timestamp
            };
          }
        } catch (error) {
          alert("Невозможно сжать содержимое кэша для хранилища: ");
        }
        try {
          value_json = JSON.stringify(cache_value);
          if (value_json) {
            window.localStorage.setItem(key, value_json);
          }
        } catch (error1) {
          e = error1;
          if (e === QUOTA_EXCEEDED_ERR) {
            alert("Локальное хранилище переполнено");
          }
        }
      }
      if (key && !value) {
        stored_json = window.localStorage.getItem(key);
        if (stored_json) {
          res = JSON.parse(stored_json);
          if (/^pg#/.test(key)) {
            res.value = LZString.decompressFromUTF16(res.v);
          } else {
            res.value = res.v;
          }
        } else {
          res = {
            v: null,
            t: null,
            value: null
          };
        }
      }
    } else {
      if (key && value) {
        NavigationCache[key] = value;
      }
      if (key && !value) {
        res = NavigationCache[key];
      }
    }
    return res;
  };

  window.if_console = function(params) {
    if (true) {
      return console.log(params);
    }
  };

  window.objects_equal = function(obj1, obj2) {
    return JSON.stringify(obj1) === JSON.stringify(obj2);
  };

  window.need_run = function(proc_name, delta) {
    var cache_name, last_run, res;
    if (delta == null) {
      delta = 1;
    }
    cache_name = "lr#" + proc_name;
    last_run = window.varCache(cache_name);
    window.varCache(cache_name, "...");
    res = true;
    if (last_run && last_run.t && window.current_timestamp() - last_run.t < delta * 1000) {
      res = false;
    }
    return res;
  };

  window.stop = function(e) {
    if (e.preventDefault) {
      e.preventDefault();
      e.stopPropagation();
    } else {
      e.returnValue = false;
      e.cancelBubble = true;
    }
  };

  window.is_empty = function(value) {
    var prop, res;
    switch (typeof value) {
      case "object":
        res = true;
        for (prop in value) {
          if (value.hasOwnProperty(prop)) {
            res = false;
            break;
          }
        }
        return res;
      case "number":
        return false;
      case "string":
        return value === "";
      case "undefined":
        return true;
      default:
        return false;
    }
  };

  window.calculate_visibilities = function(params) {
    var res;
    res = {};
    res.document_height = params.jquery_document.height();
    params.document_height = res.document_height;
    res.is_header_visible = params.scroll_top < params.header_height - params.top_menu_height;
    res.is_footer_visible = res.document_height - params.view_size.height - params.scroll_top - params.footer_height <= 0;
    if (params.view_size.height < params.performers_filter_height) {
      res.is_footer_reachable = res.document_height - params.scroll_top - params.footer_height <= params.performers_filter_height + params.top_menu_height;
    } else {
      res.is_footer_reachable = res.document_height - params.performers_filter_height - params.scroll_top - params.footer_height - params.top_menu_height <= 0;
    }
    return res;
  };

  window.numberWithCommas = function(x) {
    var parts;
    parts = x.toString().split(".");
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, " ");
    return parts.join(".");
  };

  window.fancybox_init = function() {
    return $(".fancybox").fancybox({
      beforeLoad: function() {
        return this.title = $(this.element).attr("caption");
      },
      helpers: {
        overlay: {
          locked: false
        }
      }
    });
  };

  window.myFireEvent = function(event_name) {
    var event;
    event = void 0;
    if (document.createEvent) {
      event = document.createEvent("HTMLEvents");
      event.initEvent(event_name, true, true);
    } else {
      event = document.createEventObject();
      event.eventType = event_name;
    }
    event.eventName = event_name;
    if (document.createEvent) {
      return element.dispatchEvent(event);
    } else {
      return element.fireEvent("on" + event.eventType, event);
    }
  };

  window.current_timestamp = function() {
    return new Date().getTime();
  };

  window.current_date = function(inc_days) {
    var date;
    if (inc_days == null) {
      inc_days = 0;
    }
    date = new Date();
    date.setDate(date.getDate() + inc_days);
    return date.getDate() + ' ' + window.date_time_names["fullMonthNames"][date.getMonth()] + ' ' + date.getFullYear();
  };

  window.getWindowSize = function() {
    var IS_BODY_ACTING_ROOT, b, docEl, isDocumentElementHeightOff;
    isDocumentElementHeightOff = function() {
      var d, div, r;
      d = document;
      div = d.createElement("div");
      div.style.height = "2500px";
      d.body.insertBefore(div, d.body.firstChild);
      r = d.documentElement.clientHeight > 2400;
      d.body.removeChild(div);
      return r;
    };
    docEl = document.documentElement;
    IS_BODY_ACTING_ROOT = docEl && docEl.clientHeight === 0;
    if (typeof document.clientWidth === "number") {
      return {
        width: document.clientWidth,
        height: document.clientHeight
      };
    } else if (IS_BODY_ACTING_ROOT || isDocumentElementHeightOff()) {
      b = document.body;
      return {
        width: b.clientWidth,
        height: b.clientHeight
      };
    } else {
      return {
        width: docEl.clientWidth,
        height: docEl.clientHeight
      };
    }
  };

  window.get_attr = function(element, attr_name, depth) {
    var j, level, r, ref, res;
    if (depth == null) {
      depth = 1;
    }
    res = [];
    r = element;
    for (level = j = 1, ref = depth; 1 <= ref ? j <= ref : j >= ref; level = 1 <= ref ? ++j : --j) {
      if (r) {
        res.push($(r).attr(attr_name));
        r = r.parentNode;
      }
    }
    return res.first_not_empty();
  };

  String.prototype.alltrim = function() {
    return this.replace(/\n/g, '').replace(/^\s*/, '').replace(/\s*$/, '');
  };

  Array.prototype.scan = function(value) {
    return this.indexOf(value || -1);
  };

  Array.prototype.max = function() {
    return Math.max.apply(null, this);
  };

  Array.prototype.min = function() {
    return Math.min.apply(null, this);
  };

  Array.prototype.first_not_empty = function() {
    var j, len, res;
    res = null;
    for (j = 0, len = this.length; j < len; j++) {
      res = this[j];
      if (res) {
        break;
      }
    }
    return res;
  };

  window.activate_first_input = function(selector) {
    return $(selector + " input[type!=hidden]:first").focus();
  };

  window.dialog = function(html) {
    var id;
    id = "dialog" + (window.current_timestamp());
    return $.fancybox({
      content: "<div id='fancybox-content'>" + html + "</div>",
      padding: 40,
      tpl: {
        closeBtn: "<span id=\"cancel\" class=\"m10 pull-right fancybox-item fancybox-close fancy-close glyph glyph-remove glyph-close\"></span>"
      },
      helpers: {
        overlay: {
          locked: false,
          speedOut: 500,
          css: {
            'background-color': 'rgba(11,11,11,0.2)'
          }
        }
      },
      afterShow: function() {
        return window.activate_first_input("#fancybox-content");
      }
    });
  };

  window.render_page = function(page_html, page_url) {
    if (page_url == null) {
      page_url = "";
    }
    $.fancybox.close();
    if (/full-screen/.test(page_html)) {
      $(window.content_selector).html(page_html);
      window.activate_first_input(window.content_selector);
      if (page_url) {
        history.pushState({
          page: page_url,
          type: "page"
        }, document.title, page_url);
        window.varCache("pg#" + page_url, page_html);
      }
    } else {
      dialog(page_html);
    }
    return window.front_doc_ready();
  };

  window.get_ajax = function(url, data_adds, callback, callback_params, async, query_type, datatype) {
    var data, key, val;
    if (callback == null) {
      callback = null;
    }
    if (callback_params == null) {
      callback_params = null;
    }
    if (async == null) {
      async = true;
    }
    if (query_type == null) {
      query_type = "GET";
    }
    if (datatype == null) {
      datatype = "json";
    }
    data = {
      utf8: "\?",
      layout: false,
      authenticity_token: window.get_token()
    };
    for (key in data_adds) {
      val = data_adds[key];
      data[key] = val;
    }
    return $.ajax({
      async: async,
      type: query_type,
      datatype: datatype,
      data: data,
      url: url,
      error: function(data) {
        if (callback) {
          return callback(data, callback_params);
        } else {
          return data;
        }
      },
      success: function(data) {
        if (callback) {
          return callback(data, callback_params);
        } else {
          return data;
        }
      }
    });
  };

  window.timezone_name = function() {
    return Intl.DateTimeFormat().resolvedOptions().timeZone;
  };

  window.get_token = function() {
    return $('meta[name="csrf-token"]').attr('content');
  };

  window.status_body = function(status, html, seconds) {
    var div, left, top, wrapper;
    if (seconds == null) {
      seconds = null;
    }
    wrapper = "_wrapper";
    div = "div";
    if (seconds === 0) {
      $("#" + status + wrapper + " > " + div + ".data-message").html(html);
      $("#" + status + wrapper + " > " + div + ".data-transparent").css({
        opacity: 0.9
      });
      return $("#" + status + wrapper).css({
        top: "0px"
      });
    } else {
      if (!seconds) {
        seconds = 4;
      }
      seconds *= 1000;
      if ($("#" + status + wrapper + " > " + div + ".data-transparent").is(':animated')) {
        $("#" + status + wrapper + " > " + div + ".data-transparent").stop();
      }
      if ($("#" + status + wrapper + " > " + div + ".data-message").is(':animated')) {
        $("#" + status + wrapper + " > " + div + ".data-message").stop();
      }
      if ($("#" + status + wrapper).is(':animated')) {
        $("#" + status + wrapper).stop();
      }
      $("#" + status + wrapper).css({
        opacity: 0.9,
        top: "0px"
      });
      $("#" + status + wrapper + " > " + div + ".data-message").html(html);
      left = ($("#" + status + wrapper).width() - $("#" + status + wrapper + " > .data-message").width()) / 2;
      top = ($("#" + status + wrapper).height() - $("#" + status + wrapper + " > .data-message").height()) / 2;
      $("#" + status + wrapper + " > .data-message").css({
        top: top + "px",
        left: left + "px"
      });
      $("#" + status + wrapper + " > " + div + ".data-transparent").css({
        opacity: 0.9
      });
      $("#" + status + wrapper + " > " + div + ".data-message").css({
        opacity: 1
      });
      $("#" + status + wrapper + " > " + div + ".data-transparent").animate({
        opacity: 0,
        WebkitTransition: "opacity 2s ease-in-elastic",
        MozTransition: "opacity 2s ease-in-elastic",
        MsTransition: "opacity 2s ease-in-elastic",
        OTransition: "opacity 2s ease-in-elastic",
        transition: "opacity 2s ease-in-elastic"
      }, seconds, function() {});
      return $("#" + status + wrapper + " > " + div + ".data-message").animate({
        opacity: 0
      }, seconds, function() {
        return $("#" + status + wrapper).css({
          opacity: 0,
          top: "-200px"
        });
      });
    }
  };

  'use strict';

  window.save_current_page = function() {
    var content;
    content = $("#content").html();
    return window.varCache(window.current_location(), content);
  };

  window.current_location = function() {
    return decodeURI(window.location.pathname + window.location.search);
  };

  window.get_form_fields = function(v) {
    var field_value_caller, field_value_func_name, field_value_params;
    field_value_caller = v ? v.split(/\(|\)/) : [];
    field_value_func_name = field_value_caller[0];
    field_value_params = field_value_caller[1] ? field_value_caller[1].replace(/\'|\"/g, '').split(',') : [];
    if (field_value_params.length === 1) {
      field_value_params = field_value_params[0];
    } else if (field_value_params.length === 0) {
      field_value_params = "";
    }
    return [field_value_func_name, field_value_params];
  };

  window.get_specialization_name = function(url) {
    var decoded_uri, url_specialization, url_specialization_matches;
    url_specialization = void 0;
    decoded_uri = decodeURIComponent(url);
    if (decoded_uri) {
      url_specialization_matches = decoded_uri.match(/[^\/]+$/);
      if (url_specialization_matches && url_specialization_matches.length > 0) {
        url_specialization = url_specialization_matches[0];
      }
    }
    return url_specialization;
  };

  window.store_form_values = function() {
    var elem, j, len, params, ref, tagName;
    params = {};
    ref = $("[data-storeable]");
    for (j = 0, len = ref.length; j < len; j++) {
      elem = ref[j];
      tagName = $(elem).prop("tagName").toLowerCase();
      if (/input/.test(tagName) && elem.getAttribute("type") === "checkbox") {
        params["checkbox#" + ($(elem).prop('id'))] = elem.checked;
      } else if (/select|input|textarea/.test(tagName) || (/div/.test(tagName) && /sliders/.test($(elem).attr("class")))) {
        params[tagName + "#" + ($(elem).prop('id'))] = $(elem).val();
      } else if (/label/.test(tagName)) {
        params[tagName + "#" + ($(elem).prop('id'))] = $(elem).text().alltrim();
      }
    }
    if (!window.is_empty(params)) {
      return window.varCache("sv" + (window.current_location()), params);
    }
  };

  window.restore_form_values = function() {
    var cache, id, key, ref, results, value;
    cache = window.varCache("sv" + (window.current_location()));
    if (cache && !cache.value || !cache) {
      window.store_form_values();
    }
    cache = window.varCache("sv" + (window.current_location()));
    if (cache && cache.value) {
      ref = cache.value;
      results = [];
      for (key in ref) {
        value = ref[key];
        if (/^checkbox/.test(key)) {
          id = key.replace(/^checkbox#/, '');
          if (document.getElementById(id)) {
            results.push(document.getElementById(id).checked = value);
          } else {
            results.push(void 0);
          }
        } else if (/^(select|input|textarea)/.test(key) || (/^div/.test(key) && /slider/.test(key))) {
          if ($(key).length > 0) {
            results.push($(key).val(value));
          } else {
            results.push(void 0);
          }
        } else {
          results.push(void 0);
        }
      }
      return results;
    }
  };

  window.read_form_values = function() {
    return window.varCache("sv" + (window.current_location())).value;
  };

  window.set_style = function(selector, rules) {
    var css_selector, key, rules_str, sheet, style_str;
    css_selector = "cs" + (selector.replace(/[\.\,#]/, '-'));
    sheet = document.createElement("style");
    sheet.id = css_selector;
    style_str = selector + " {<rules>}";
    rules_str = "";
    for (key in rules) {
      rules_str += key + ": " + rules[key] + ";";
    }
    sheet.innerHTML = style_str.replace("<rules>", rules_str);
    if (!document.getElementById(css_selector)) {
      return document.body.appendChild(sheet);
    } else {
      return document.getElementById(css_selector).innerHTML = sheet.innerHTML;
    }
  };

  window.popup = function(html) {
    var back_stage, popup;
    popup = document.createElement("div");
    popup.className = window.popup_class;
    popup.innerHTML = html;
    back_stage = document.createElement("div");
    back_stage.className = window.back_stage_class;
    document.body.appendChild(back_stage);
    return document.body.appendChild(popup);
  };

  window.initialize_checkboxes = function() {
    var checkbox, id, j, label_text, len, ref, results;
    ref = $("input[type='checkbox']");
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      checkbox = ref[j];
      id = checkbox.getAttribute("id");
      label_text = checkbox.getAttribute("data-label");
      results.push(window.set_style("input#" + id + ":after", [["content", "'" + label_text + "'"]]));
    }
    return results;
  };

  window.makeid = function(length_of) {
    var i, possible, text;
    text = "";
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    i = 0;
    while (i < length_of) {
      text += possible.charAt(Math.floor(Math.random() * possible.length));
      i++;
    }
    return text;
  };

  window.init_session = function() {
    var cacheSessionId, sId;
    sId = "sId";
    cacheSessionId = varCache(sId);
    if (!cacheSessionId || !cacheSessionId.value) {
      return varCache(sId, window.makeid(32));
    }
  };

  window.insert_rows = function(data, params) {
    return $(".table > table").append(data);
  };

  window.get_parent_model_name = function() {
    return $("[" + window.data_parent_model_name_attr + "]").attr(window.data_parent_model_name_attr);
  };

  window.get_parent_record_id = function() {
    return $("[" + window.data_parent_model_name_attr + "]").attr(window.data_parent_record_id_attr);
  };

  window.url_by_model = function(id) {
    var url;
    if (id == null) {
      id = null;
    }
    url = "/admin/" + (window.get_parent_model_name());
    if (id) {
      url = url + ("/" + id);
    }
    return url;
  };

  window.set_file_listener = function(model_name) {
    if (model_name == null) {
      model_name = null;
    }
    $("#input-file").change(function(e) {
      return window.upload_performer_photos(e, window.upload_preview_selector);
    });
    $("#upload-other-performer-photos").change(function(e) {
      return window.upload_performer_photos(e, "#devise-other-performer-photos");
    });
    $("#upload-performer-avatar").change(function(e) {
      return window.upload_performer_avatar(e);
    });
    return $("#upload-main-performer-photo").change(function(e) {
      return window.upload_main_performer_photo(e);
    });
  };

  window.upload_performer_photos = function(e, upload_preview_selector) {
    var existing_file_ids, fast_preview, file, file_id, id, input, j, len, model_name, o, readers, ref, style_template, template_name;
    style_template = "!!!style!!!";
    if (!model_name) {
      model_name = window.get_parent_model_name();
    }
    existing_file_ids = [];
    input = $(e.currentTarget);
    id = input.attr("id");
    readers = [];
    ref = input[0].files;
    for (j = 0, len = ref.length; j < len; j++) {
      file = ref[j];
      file_id = window.makeid(7);
      template_name = "img_thumb";
      fast_preview = HandlebarsTemplates[template_name]({
        "data-model": model_name,
        thumb: "/assets/images/thumb_dumb.gif",
        attachment_comment: file.name,
        id: file_id
      });
      $(upload_preview_selector).append(fast_preview);
      o = new FileReader();
      o.file_id = file_id;
      o.file = file;
      o.readAsDataURL(file);
      o.onload = function(e) {
        var image_base64, image_hash, pic_real_height, pic_real_width, pic_scaled_height, pic_scaled_width, preloaded_image, preview, record_id;
        image_base64 = e.target.result;
        image_hash = sha512(image_base64);
        preview = HandlebarsTemplates[template_name]({
          "data-model": model_name,
          thumb: image_base64,
          thumb: image_base64,
          attachment_comment: this.file.name,
          id: this.file_id,
          image_hash: image_hash
        });
        pic_real_width = void 0;
        pic_scaled_width = void 0;
        pic_real_height = void 0;
        pic_scaled_height = 200;
        preloaded_image = $("<img id='" + this.file_id + "'/>");
        preloaded_image.file_id = this.file_id;
        preloaded_image.load(function() {
          var preloaded_image_id;
          preloaded_image_id = $(this)[0].id;
          $("#" + preloaded_image_id).replaceWith(preview);
          pic_real_width = this.width;
          pic_real_height = this.height;
          pic_scaled_width = pic_real_width * (pic_scaled_height / pic_real_height);
          $("#" + preloaded_image_id + " img").css({
            width: pic_scaled_width + "px",
            height: pic_scaled_height + "px"
          });
        }).attr("src", image_base64);
        record_id = window.get_parent_record_id();
        return window.upload(this.file, this.file_id, image_hash, model_name, record_id, preloaded_image[0].width, preloaded_image[0].height);
      };
    }
    return document.getElementById(id).value = "";
  };

  window.upload_performer_avatar = function(e) {
    var existing_file_ids, fast_preview, file, file_id, id, input, j, len, model_name, o, readers, ref, style_template, template_name;
    style_template = "!!!style!!!";
    if (!model_name) {
      model_name = window.get_parent_model_name();
    }
    existing_file_ids = [];
    input = $(e.currentTarget);
    id = input.attr("id");
    readers = [];
    ref = input[0].files;
    for (j = 0, len = ref.length; j < len; j++) {
      file = ref[j];
      file_id = window.makeid(7);
      template_name = "avatar_preview";
      fast_preview = HandlebarsTemplates[template_name]({
        "data-model": model_name,
        thumb: "/assets/images/thumb_dumb.gif",
        attachment_comment: file.name,
        id: file_id
      });
      window.popup(fast_preview);
      o = new FileReader();
      o.file_id = file_id;
      o.file = file;
      o.readAsDataURL(file);
      o.onload = function(e) {
        var image_base64, image_hash, pic_real_height, pic_real_width, pic_scaled_height, pic_scaled_width, preloaded_image, preview, record_id;
        image_base64 = e.target.result;
        image_hash = sha512(image_base64);
        preview = HandlebarsTemplates[template_name]({
          "data-model": model_name,
          src: image_base64,
          thumb: image_base64,
          attachment_comment: this.file.name,
          id: this.file_id,
          image_hash: image_hash
        });
        pic_real_width = void 0;
        pic_scaled_width = void 0;
        pic_real_height = void 0;
        pic_scaled_height = 200;
        $(".popup").html(preview);
        $(".popup img").css({
          height: "400px",
          top: ((window.getWindowSize().height - 400) / 2) + "px"
        });
        pic_scaled_height = [window.getWindowSize().height * 0.8, 400].min();
        preloaded_image = $("<img id='" + this.file_id + "'/>");
        preloaded_image.file_id = this.file_id;
        preloaded_image.load(function() {
          var preloaded_image_id, styles;
          preloaded_image_id = $(this)[0].id;
          $("#" + preloaded_image_id).replaceWith(preview);
          pic_real_width = this.width;
          pic_real_height = this.height;
          pic_scaled_width = pic_real_width * (pic_scaled_height / pic_real_height);
          styles = [[window.top_attr, ((window.getWindowSize().height - pic_scaled_height) / 2) + "px"], [window.left_attr, ((window.getWindowSize().width - pic_scaled_width) / 2) + "px"]];
          window.set_style(".popup", styles);
          $("#" + preloaded_image_id + " img").css({
            width: pic_scaled_width + "px",
            height: pic_scaled_height + "px"
          });
        }).attr("src", image_base64);
        record_id = window.get_parent_record_id();
        return window.upload(this.file, this.file_id, image_hash, model_name, record_id, preloaded_image[0].width, preloaded_image[0].height);
      };
    }
    return document.getElementById(id).value = "";
  };

  window.upload_main_performer_photo = function(e) {
    var existing_file_ids, fast_preview, file, file_id, id, input, j, len, model_name, o, readers, ref, template_name;
    existing_file_ids = [];
    input = $(event.currentTarget);
    id = input.attr("id");
    readers = [];
    model_name = "performers";
    ref = input[0].files;
    for (j = 0, len = ref.length; j < len; j++) {
      file = ref[j];
      file_id = window.makeid(7);
      template_name = "img_thumb";
      fast_preview = HandlebarsTemplates[template_name]({
        "data-model": model_name,
        src: "/assets/images/thumb_dumb.gif",
        attachment_comment: file.name,
        id: file_id
      });
      $(window.upload_preview_selector).html(fast_preview);
      o = new FileReader();
      o.file_id = file_id;
      o.file = file;
      o.readAsDataURL(file);
      o.onload = function(e) {
        var image_base64, image_hash, pic_real_height, pic_real_width, pic_scaled_height, pic_scaled_width, preloaded_image, preview, record_id;
        image_base64 = e.target.result;
        image_hash = sha512(image_base64);
        preview = HandlebarsTemplates[template_name]({
          "data-model": model_name,
          src: image_base64,
          thumb: image_base64,
          attachment_comment: this.file.name,
          id: this.file_id,
          image_hash: image_hash
        });
        pic_real_width = void 0;
        pic_scaled_width = void 0;
        pic_real_height = void 0;
        pic_scaled_height = 200;
        preloaded_image = $("<img id='" + this.file_id + "'/>");
        preloaded_image.file_id = this.file_id;
        preloaded_image.load(function() {
          var preloaded_image_id;
          preloaded_image_id = $(this)[0].id;
          $("#" + preloaded_image_id).replaceWith(preview);
          pic_real_width = this.width;
          pic_real_height = this.height;
          pic_scaled_width = pic_real_width * (pic_scaled_height / pic_real_height);
          $("#" + preloaded_image_id + " img").css({
            width: pic_scaled_width + "px",
            height: pic_scaled_height + "px"
          });
        }).attr("src", image_base64);
        record_id = window.get_parent_record_id();
        return window.upload(this.file, this.file_id, image_hash, model_name, record_id, preloaded_image[0].width, preloaded_image[0].height);
      };
    }
    return document.getElementById(id).value = "";
  };

  window.render_face_squares = function(params, data) {
    var diameter, face, img, index, j, len, ref, res, results;
    res = params.res;
    img = $(".popup img");
    window.squares = [];
    window.original_image_filename = res.original_image_filename;
    window.original_image_width = res.original_image_width;
    window.original_image_height = res.original_image_height;
    window.pic_width = parseInt(img.css("width"));
    window.pic_height = parseInt(img.css("height"));
    window.kx = window.pic_width / window.original_image_width;
    window.ky = window.pic_height / window.original_image_height;
    window.result_avatar_height = $(window.result_avatar_selector).height();
    window.kmed = Math.sqrt(window.kx * window.ky);
    window.padding = parseInt($(".popup").css("padding"));
    window.k = window.pic_width / window.pic_height;
    window.selected_square_index = 0;
    if (res.faces.length > 0) {
      ref = res.faces;
      results = [];
      for (index = j = 0, len = ref.length; j < len; index = ++j) {
        face = ref[index];
        window.squares.push({
          top: face.top,
          left: face.left,
          diameter: face.diameter
        });
        $(".popup").append("<div id='face-round-" + index + "' draggable='true'></div>");
        window.set_square_style(index);
        if (index === window.selected_square_index) {
          results.push(window.set_result_square(index));
        } else {
          results.push(void 0);
        }
      }
      return results;
    } else {
      diameter = 100 + window.padding * 4;
      window.squares.push({
        top: 100,
        left: 100,
        diameter: diameter
      });
      $(".popup").append("<div id='face-round-0' draggable='true'></div>");
      window.set_square_style(0);
      return window.set_result_square(0);
    }
  };

  document.ondragstart = function(e) {
    e.dataTransfer.setData('index', index_from_str(e.target.id));
    e.dataTransfer.setData('mouse_x', e.clientX);
    return e.dataTransfer.setData('mouse_y', e.clientY);
  };

  document.ondragover = function(e) {
    return e.preventDefault();
  };

  document.ondrop = function(e) {
    var img, index, old_mouse_x, old_mouse_y, square;
    index = e.dataTransfer.getData("index");
    old_mouse_x = parseInt(e.dataTransfer.getData("mouse_x"));
    old_mouse_y = parseInt(e.dataTransfer.getData("mouse_y"));
    square = $("#face-round-" + index);
    img = $(".popup img");
    index = index_from_str($(square).attr("id"));
    window.squares[index].top = window.squares[index].top + (e.clientY - old_mouse_y) / window.kx;
    window.squares[index].left = window.squares[index].left + (e.clientX - old_mouse_x) / window.ky;
    window.selected_square_index = index;
    window.set_square_style(index);
    return window.set_result_square(index);
  };

  window.set_result_square = function(index) {
    var background_of_result_avatar_height, background_of_result_avatar_width, background_position_left, background_position_top, j, len, ref, selected_square, selected_square_height, selected_square_left, selected_square_top, square;
    selected_square = $(".popup #face-round-" + index);
    ref = $(".popup [id^='face-round-']");
    for (j = 0, len = ref.length; j < len; j++) {
      square = ref[j];
      $(square).css({
        "background-color": "transparent"
      });
    }
    selected_square.css({
      "background-color": "white",
      "opacity": "0.2"
    });
    selected_square_height = selected_square.height();
    selected_square_left = parseInt(selected_square.css(window.left_attr)) - window.padding;
    selected_square_top = parseInt(selected_square.css(window.top_attr)) - window.padding;
    background_of_result_avatar_height = window.pic_height / selected_square_height * window.result_avatar_height;
    background_of_result_avatar_width = background_of_result_avatar_height * window.k;
    background_position_left = [0, -1 * selected_square_left * (window.result_avatar_height / selected_square_height)].min();
    background_position_top = [0, -1 * selected_square_top * (window.result_avatar_height / selected_square_height)].min();
    return window.set_style(window.result_avatar_selector, [["background-image", "url(" + ($('.popup img').attr('src')) + ")"], ["background-position", background_position_left + "px " + background_position_top + "px"], ["background-size", background_of_result_avatar_width + "px " + background_of_result_avatar_height + "px"]]);
  };

  window.set_square_style = function(index) {
    var diameter, left, square, top;
    square = $(".popup #face-round-" + index);
    diameter = window.squares[index].diameter;
    top = window.squares[index].top;
    left = window.squares[index].left;
    return square.css({
      width: (diameter * window.kx) + "px",
      height: (diameter * window.ky) + "px",
      top: (top * window.ky + window.padding) + "px",
      left: (left * window.kx + window.padding) + "px",
      "border-radius": (diameter * window.kmed / 2) + "px",
      "-webkit-border-radius": (diameter * window.kmed / 2) + "px",
      "-moz-border-radius": (diameter * window.kmed / 2) + "px"
    });
  };

  $(document).click(function(e) {
    if (/reduce/.test(e.target.className)) {
      window.on_reduce_click(e);
    }
    if (/increase/.test(e.target.className)) {
      window.on_increase_click(e);
    }
    if (/^face-round-\d+/.test(e.target.id)) {
      window.on_face_round_click(e);
    }
    if (/^btn-avatar-confirm$/.test(e.target.id)) {
      return window.confirm_avatar();
    }
  });

  window.confirm_avatar = function() {
    return window.get_ajax("/set_avatar", {
      original_image: {
        filename: window.original_image_filename,
        width: window.original_image_width,
        height: window.original_image_height
      },
      scaled_image: {
        width: window.pic_width,
        height: window.pic_height,
        padding: window.padding
      },
      selected: {
        top: window.squares[window.selected_square_index].top,
        left: window.squares[window.selected_square_index].left,
        diameter: window.squares[window.selected_square_index].diameter
      }
    }, set_avatar);
  };

  set_avatar = function(data, params) {
    var background_of_result_avatar_height, background_of_result_avatar_width, background_position_left, background_position_top;
    $(".popup").remove();
    $(".back-stage").remove();
    $("#devise-client-avatar").remove();
    $("#upload-performer-avatar").before("<div id='devise-client-avatar'></div>");
    background_position_left = 0;
    background_position_top = 0;
    background_of_result_avatar_width = 100;
    background_of_result_avatar_height = 100;
    return window.set_style("#devise-client-avatar", [["background-image", "url(http://" + window.location.hostname + "/" + data.avatar_image_file_name + "?)"], ["background-position", background_position_left + "px " + background_position_top + "px"], ["background-size", background_of_result_avatar_width + "px " + background_of_result_avatar_height + "px"], ["width", background_of_result_avatar_width + "px"], ["height", background_of_result_avatar_height + "px"], ["border-radius", (background_of_result_avatar_width / 2) + "px"], ["-webkit-border-radius", (background_of_result_avatar_width / 2) + "px"], ["-moz-border-radius", (background_of_result_avatar_width / 2) + "px"], ["cursor", "pointer"]]);
  };

  index_from_str = function(str) {
    return parseInt(str.match(/\d+/));
  };

  window.on_face_round_click = function(e) {
    var index;
    index = index_from_str(e.target.id);
    if (index === window.selected_square_index) {
      return window.confirm_avatar();
    } else {
      window.set_result_square(index);
      return window.selected_square_index = index;
    }
  };

  window.on_reduce_click = function(e) {
    var index;
    index = window.selected_square_index;
    window.squares[index].diameter = window.squares[index].diameter * 0.9;
    window.set_square_style(index);
    return window.set_result_square(index);
  };

  window.on_increase_click = function(e) {
    var index;
    index = window.selected_square_index;
    window.squares[index].diameter = window.squares[index].diameter / 0.9;
    window.set_square_style(index);
    return window.set_result_square(index);
  };

  window.onUploadSuccess = function(e, bar_id) {
    var attachment_filename, attachment_id;
    $("#" + bar_id + " progress").css({
      opacity: 0
    });
    attachment_id = $('.attachment').attr('id');
    attachment_filename = JSON.parse(e.responseText)["filename"];
    $("#" + bar_id + " img").attr({
      src: "/" + attachment_filename
    });
    if ($("#upload-performer-avatar").length > 0) {
      return window.get_ajax("/fcd", {
        picture: attachment_filename
      }, window.render_face_squares, {});
    }
  };

  window.onUploadError = function(e) {};

  window.onUploadProgress = function(loaded, total, bar_id) {
    $("#" + bar_id + " progress").attr("value", "" + (loaded / total * 100));
    return $("#" + bar_id + " progress").css({
      display: "block"
    });
  };

  window.upload = function(file, bar_id, attachment_hash, model_name, record_id, image_width, image_height) {
    var image_sizes, xhr;
    if (!record_id) {
      window.status_body("error", HandlebarsTemplates[wrong_id_template](), 7);
      return;
    }
    xhr = new XMLHttpRequest();
    xhr.onload = xhr.onerror = function() {
      if (this.status !== 200) {
        window.onUploadError(this);
        return;
      }
      window.onUploadSuccess(this, bar_id);
    };
    xhr.upload.onprogress = function(event) {
      window.onUploadProgress(event.loaded, event.total, bar_id);
    };
    image_sizes = "&image_width=" + image_width + "&image_height=" + image_height;
    window.save_master(record_id);
    xhr.open("POST", "/upload_something?file_name=" + file.name + "&attachment_hash=" + attachment_hash + "&attachmentable_type=" + model_name + "&attachmentable_id=" + record_id + image_sizes, true);
    xhr.setRequestHeader('X-CSRF-Token', window.get_token());
    return xhr.send(file);
  };

  window.save_master = function(id) {
    if (!id) {
      return window.status_body("error", HandlebarsTemplates[wrong_id_template](), 7);
    }
  };

  window.set_page_sign = function(sign_string) {
    return $(window.content_selector).attr("data-page-sign", sign_string);
  };

  window.get_page_sign = function() {
    return $(window.content_selector).attr("data-page-sign");
  };

}).call(this);
