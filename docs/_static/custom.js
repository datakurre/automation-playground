function handleClickAndPress(myfunc) {
  return function (e) {
    if (e.type != "keypress" || e.keyCode == 13) {
       myfunc(e);
    }
 };
}

// $("#click-and-press").bind("click keypress", handleClickAndPress(function (e) {
//   addToBody(); // Works on click and keypress
// }));

jQuery(function($) {
  $('a[href$=".bpmn"]').each(function(id, el) {
    var play = $('<button class="icon fa-play" title="Token simulation"/>');
    var stop = $('<button class="icon fa-stop" title="Close simulation"/>');
    var id = "simulation-" + Math.floor(Math.random() * (new Date().getTime()));
    play.bind("click keypress", handleClickAndPress(function (e) {
      if (!document.getElementById(id)) {
        play.hide();
        stop.show().focus();
        if ($(el).parents("figcaption").length) {
          $(el).parents("figcaption").siblings().hide();
          $(el).parents("figcaption").before('<div id="'+ id + '"/>');
        } else {
          stop.after('<div id="'+ id + '"/>');
        }
        TokenSimulation(id, $(el).attr("href"));
      }
    }));
    stop.bind("click keypress", handleClickAndPress(function (e) {
      if (document.getElementById(id)) {
        $('#' + id).remove();
        stop.hide();
        play.show().focus();
        if ($(el).parents("figcaption").length) {
          $(el).parents("figcaption").siblings().show();
        }
      }
    }));
    stop.hide();

    if ($(el).parents("figcaption").length) {
      $(el).parents("figcaption").children().first().prepend(play).prepend(stop);
    } else {
      $(el).after(play).after(stop);
    }
  })
});
