# http://awesomeful.net/posts/47-sortable-lists-with-jquery-in-rails

# This sets up the proper header for rails to understand the request type,
# and therefore properly respond to js requests (via respond_to block, for example)
$.ajaxSetup 'beforeSend': (xhr) -> 
  xhr.setRequestHeader "Accept", "text/javascript"
