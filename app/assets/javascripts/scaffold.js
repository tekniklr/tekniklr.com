window.notify = function(message, cssclass, div) {
  cssclass = (typeof cssclass !== 'undefined') ?  cssclass : 'notice';
  div = (typeof div !== 'undefined') ?  div : '#notification';
  $(div).html(''); // if we don't do this the message 'flashes' before appearing
  $(div).hide(300);
  $(div).html('<div class="flash ' + cssclass + '">' + message + '</div>');
  $(div).show(300);
  return false;
};
