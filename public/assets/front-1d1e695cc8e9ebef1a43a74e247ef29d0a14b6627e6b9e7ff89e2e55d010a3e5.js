(function() {
  var check_answer, render_question;

  $(document).click(function(e) {
    return window.document_onclick(e);
  });

  window.document_onclick = function(e) {
    var answer_id, input_element, question_id;
    if ($(e.target).data("ajax") === 1) {
      if ($(e.target).data("type") === "answer_variant") {
        question_id = $(e.target).data("question-id");
        answer_id = $(e.target).data("answer-id");
        window.status_body("info", HandlebarsTemplates["info"]({
          message: "Ответ принят..."
        }), 0);
        window.get_ajax("/check_answer", {
          client_id: window.client_identify(),
          question_id: question_id,
          answer_id: answer_id,
          question_list: $("#question-list").data("question-list")
        }, check_answer);
      }
    }
    if (/btn-fancy-close/.test(e.target.className)) {
      $(".fancybox-opened").remove();
      $(".fancybox-overlay").remove();
    }
    if (/btn-next/.test(e.target.className)) {
      window.next_question();
    }
    if (/search/.test(e.target.getAttribute('data-ajax'))) {
      if (/black/.test(e.target.className)) {
        e.target.className = e.target.className.replace(' black', '');
        return e.target.parentNode.outerHTML = e.target.parentNode.outerHTML.replace(/<input[^>]+>/, '');
      } else {
        input_element = document.createElement('input');
        input_element.className = 'pull-right search';
        e.target.className = e.target.className + ' black';
        return e.target.outerHTML = input_element.outerHTML + e.target.outerHTML;
      }
    }
  };

  window.next_question = function() {
    return window.get_ajax(window.location.pathname, {
      layout: false,
      client_id: window.client_identify(),
      question_list: $("#question-list").data("question-list")
    }, render_question);
  };

  check_answer = function(data, params) {
    window.close_status();
    if (data.is_right) {
      window.status_body("success", HandlebarsTemplates['right_answer'], 1);
      return window.next_question();
    } else {
      return window.status_body("error", HandlebarsTemplates['wrong_answer']({
        your_answer: data.your_answer,
        right_answer: data.right_answer
      }));
    }
  };

  render_question = function(data, params) {
    var question_answered_count, question_count, right_answer_count, time_for_answers, total_answer_count, wrong_answer_count;
    window.close_status();
    $("#content").html(data);
    question_answered_count = parseInt($('#question-list').data("question-count")) - parseInt($('#question-list').data("question-left"));
    total_answer_count = parseInt($('#question-list').data("total-answers-count"));
    right_answer_count = parseInt($('#question-list').data("right-answers-count"));
    wrong_answer_count = total_answer_count - right_answer_count;
    time_for_answers = parseFloat($('#question-list').data("time-for-answers"));
    question_count = $('#question-list').data('question-count');
    window.set_style("#system-progress-bar > #wrong", {
      width: (window.getWindowSize().width * wrong_answer_count / question_count) + "px",
      left: "0px"
    });
    return window.set_style("#system-progress-bar > #right", {
      width: (window.getWindowSize().width * right_answer_count / question_count) + "px",
      left: (window.getWindowSize().width * wrong_answer_count / question_count) + "px"
    });
  };

  window.client_identify = function() {
    if (!window.varCache("cliend_id").v) {
      window.varCache("cliend_id", window.makeid(133));
    }
    return window.varCache("cliend_id").v;
  };

  $(function() {
    return window.front_doc_ready();
  });

  window.front_doc_ready = function() {
    return window.if_console(window.client_identify());
  };

}).call(this);
