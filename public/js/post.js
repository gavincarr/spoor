$(function() {
  $('.hide').hide();

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
                    '<div class="post_buttons">\n' +
                    '<span class="post_chars">' + data.post.length + '</span>\n' +
                    '<input class="post_save" type="submit" value="Save">\n' +
                    '<input class="post_save" type="submit" value="Cancel">\n' +
                    '</div><!-- post_buttons -->\n'
                   );
      $('textarea', div).focus();
    });
    return false;
  });

  // Update post text on save (if changed)
  $('div#content').delegate('.post_save', 'click', function() {
    var div = $(this).parents('div:first').parents('div:first');
    var text_elt = $('.post_text', div);
    var save_text = $('textarea', text_elt).val();
    var id = div.attr('id').replace(/^post/,'');
    // Update only if a save and text has changed
    if ($(this).val() == 'Save' && save_text.length > 0 && save_text != text_elt.data('text')) {
      $.post('/post/' + id, { 'post': save_text, forward: 1 }, function(data) {
        text_elt.html(data.post_html);
        text_elt.remove('html');
        text_elt.remove('text');
      });
    }
    else {
      text_elt.html(text_elt.data('html'));
      // Unpause posts once finished editing
      $.post('/post/' + id, { forward: 1 });
    }
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

  // Mark post as ready-to-forward
  $('div#content').delegate('.post_ffwd', 'click', function() {
    var ffwd = $(this);
    var div = ffwd.parents('div:first');
    var id = div.attr('id').replace(/^post/,'');
    $.ajax({
      type:    'POST',
      url:     '/post/' + id,
      data:     { forward: 2 },
      success: function() {
        var ts_cutoff = Math.ceil((new Date() - $('#publish_delay').text() * 1000) / 1000);
        var post_ts = $('.post_ts', div).attr('data-epoch');
        // If still time before cutoff, hide ffwd, reset to pause button if required
        if (post_ts > ts_cutoff) {
          ffwd.hide();
          if (div.hasClass('paused')) {
            // If we were paused, remove the class, and reset pause button
            div.removeClass('paused');
            $('.post_unpause', div).html('<a class="post_pause" href="" title="pause post"><img class="icon" src="/images/post_pause.png" alt="pause post"></a>');
          }
        }
        // If hit cutoff, just remove buttons
        else {
          ffwd.remove();
          $('.post_unpause', div).remove();
        }
      },
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
        pause.html('<a class="post_unpause" href=""><img class="icon" src="/images/post_unpause.png" title="unpause post" alt="unpause post"></a>');
        $('.post_ffwd', div).show();    // unhide ffwd button if hidden
        div.addClass('paused');
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
        div.removeClass('paused');
        var ts_cutoff = Math.ceil((new Date() - $('#publish_delay').text() * 1000) / 1000);
        var post_ts = $('.post_ts', div).attr('data-epoch');
        // If there's still time before the cutoff, re-display pause/ffwd buttons
        if (post_ts > ts_cutoff) {
          pause.html('<a class="post_pause" href="" title="pause post"><img class="icon" src="/images/post_pause.png" alt="pause post"></a>');
          $('.post_ffwd', div).show();  // unhide ffwd button if hidden
        }
        // If cutoff time, remove both ffwd and pause buttons
        else {
          pause.remove();
          $('.post_ffwd', div).remove();
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

  // Show/hide post_form
  $('.post_cancel').click(function() {
    $(this).parents('form:first').hide();
    $('#post_form_show').show();
    return false;
  });
  $('#post_form_show').click(function() {
    $(this).hide();
    $('#post_form').show().find('textarea').focus();
    return false;
  });

  // Show/hide post_link on div.post hover
  $('div#content').delegate('div.post', 'mouseenter', function() {
    $(this).find('a.post_link').show();
  });
  $('div#content').delegate('div.post', 'mouseleave', function() {
    $(this).find('a.post_link').hide();
  });
});
