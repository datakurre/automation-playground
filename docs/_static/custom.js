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
    var play = $('<button class="icon fa-play" title="Start simulation"/>');
    var stop = $('<button class="icon fa-stop" title="Stop simulation"/>');
    var id = "simulation-" + Math.floor(Math.random() * (new Date().getTime()));
    play.bind("click keypress", handleClickAndPress(function (e) {
      if (!document.getElementById(id)) {
        if ($(el).parents("figcaption").length && $(el).parents(".legend").length) {
          $(el).parents("figcaption").siblings().hide();
          $(el).parents(".legend").siblings().hide();
        }
        play.hide();
        stop.show().focus();
        stop.after('<div id="'+ id + '"/>');
        TokenSimulation(id, $(el).attr("href"));
      }
    }));
    stop.bind("click keypress", handleClickAndPress(function (e) {
      if (document.getElementById(id)) {
        $('#' + id).remove();
        stop.hide();
        play.show().focus();
        if ($(el).parents("figcaption").length && $(el).parents(".legend").length) {
          $(el).parents("figcaption").siblings().show();
          $(el).parents(".legend").siblings().show();
        }
      }
    }));
    stop.hide();
    $(el).after(play);
    $(el).after(stop);
  })
});
