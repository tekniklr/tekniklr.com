//= require jquery3
//= require rails-ujs
//= require navigation
//= require dialog-polyfill

// force scrollbars to always be displayed
// from https://stackoverflow.com/questions/18317634/force-visible-scrollbar-in-firefox-on-mac-os-x#
var sc;
jQuery(document).ready(function(){
  //constantly update the scroll position:
  sc=setInterval(scrollDown,200);
  //optional:stop the updating if it gets a click
  jQuery('.show_scroll').mousedown(function(e){
    clearInterval(sc);
  });
});
function scrollDown(){
  //find every div with class "show_scroll" and apply the fix
  for(i=0;i<=jQuery('.show_scroll').length;i++){
    try{
      var g=jQuery('.show_scroll')[i];
      g.scrollTop+=1;
      g.scrollTop-=1;
    } catch(e){
      //eliminates errors when no scroll is needed
    }
  }
}