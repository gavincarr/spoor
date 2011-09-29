$(function() {
  // Convert post to textarea for edit
  $('div#content').delegate('.post_edit', 'click', function() {
    var div = $(this).parents('div:first');
    var text_elt = $('.post_text', div);
    var id = div.attr('id').replace(/^post/,'');
    // Pause posts while editing
    $.post('/post/' + id, { forward: 0 });
    // Fetch the raw post to display for editing
    $.getJSON('/post/' + id + '.json', function(data) {
      $('.post_controls', div).hide();
      text_elt.data('html', text_elt.html());
      text_elt.data('text', data.post);
      text_elt.html('<textarea rows="3" cols="70">' + data.post + '</textarea>\n' +
                    '<input id="save" class="post_save" type="submit" value="Save"></input>\n' +
                    '<input class="post_save" type="submit" value="Cancel"></input>\n' +
                    '<span class="post_chars">' + data.post.length + '</span>'
                   );
    });
    return false;
  });

  // Update post text on save (if changed)
  $('div#content').delegate('.post_save', 'click', function() {
    var div = $(this).parents('div:first');
    var text_elt = $('.post_text', div);
    var save_text = $('textarea', text_elt).val();
    var id = div.attr('id').replace(/^post/,'');
    // Update only if a save and text has changed
    if ($(this).attr('id') == 'save' && save_text.length > 0 && save_text != text_elt.data('text')) {
      $.post('/post/' + id, { 'post': save_text }, function(data) {
        text_elt.html(data.post_html);
        text_elt.remove('html');
        text_elt.remove('text');
      });
    }
    else {
      text_elt.html(text_elt.data('html'));
    }
    // Unpause posts once finished editing
    $.post('/post/' + id, { forward: 1 });
    // Redisplay controls
    $('.post_controls', div).show();
    return false;
  });

  // Mark post as deleted
  $('div#content').delegate('.post_delete', 'click', function() {
    var div = $(this).parents('div:first');
    var id = div.attr('id').replace(/^post/,'');
    $.ajax({
      type:    'DELETE',
      url:     '/post/' + id,
      success: function() {
        div.hide();
      }
    });
    return false;
  });

  // Mark post as paused
  $('div#content').delegate('.post_pause', 'click', function() {
    var pause = $(this);
    var div = $(this).parents('div:first');
    var id = div.attr('id').replace(/^post/,'');
    $.ajax({
      type:    'POST',
      url:     '/post/' + id,
      data:     { forward: 0 },
      success: function() {
        pause.html('<a class="post_unpause" href=""><img class="icon" src="/images/control_play.png" title="unpause post" alt="unpause post"></a>');
        div.toggleClass('paused');
      },
    });
    return false;
  });
  // Mark post as unpaused
  $('div#content').delegate('.post_unpause', 'click', function() {
    var pause = $(this);
    var div = $(this).parents('div:first');
    var id = div.attr('id').replace(/^post/,'');
    $.ajax({
      type:    'POST',
      url:     '/post/' + id,
      data:     { forward: 1 },
      success: function() {
        var ts_cutoff = Math.ceil((new Date() - $('#publish_delay').text() * 1000) / 1000);
        var post_ts = $('.post_ts', div).attr('data-epoch');
        if (post_ts > ts_cutoff) {
          pause.html('<a class="post_pause" href=""><img class="icon" src="/images/control_pause.png" title="pause post" alt="pause post"></a>');
          div.toggleClass('paused');
        }
        else {
          pause.hide();
          div.toggleClass('paused');
        }
      },
    });
    return false;
  });

  // Character counter for post textarea
  $('div#content').delegate('textarea', 'keyup', function() {
    var div = $(this).parents('div:first');
    $('.post_chars', div).html($(this).val().length);
  });
  $('#post_data').focus(function() {
    $('#post_chars').show();
  });
});
