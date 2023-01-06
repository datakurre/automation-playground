function handleClickAndPress(myfunc) {
  return function (e) {
    if (e.type != "keypress" || e.keyCode == 13) {
       myfunc(e);
    }
 };
}

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
          $(el).after('<div id="'+ id + '"/>');
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
      $(el).before(play).before(stop);
    }
  })

  $('a[href$=".form"]').each(function(id, el) {
    var play = $('<button class="icon fa-play" title="Open form"/>');
    var stop = $('<button class="icon fa-stop" title="Close form"/>');
    var id = "form-js-" + Math.floor(Math.random() * (new Date().getTime()));
    play.bind("click keypress", handleClickAndPress(function (e) {
      if (!document.getElementById(id)) {
        play.hide();
        stop.show().focus();
        if ($(el).parents("figcaption").length) {
          $(el).parents("figcaption").siblings().hide();
          $(el).parents("figcaption").before('<div id="'+ id + '"/>');
        } else {
          $(el).after('<div id="'+ id + '"/>');
        }
        (async function() {
          const url = $(el).attr("href");
          const url2 = $(el).siblings('a[href$=".json"]').first().attr("href");
          const schema = JSON.parse(await (await (await fetch(url)).blob()).text());
          const data = await (async function() {
            if (url2) {
              try {
                return JSON.parse(await (await (await fetch(url2)).blob()).text());

              } catch (e) {
                return {};
              }
            } else {
              return {};
            }
          })();
          FormViewer.createForm({
              container: '#' + id,
              schema: schema,
              data: data
          });
        })();
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
      $(el).before(play).before(stop);
    }
  })
});
