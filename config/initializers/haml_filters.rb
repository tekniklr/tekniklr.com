Haml::Filters::Javascript.module_eval do
  alias_method :orig_render_with_options, :render_with_options

  def render_with_options(*args)
    orig_render_with_options(*args).sub(
      /\A<script([^>]*)>/, "<script\\1 nonce=\"#{Current.content_security_policy_nonce}\">"
    )
  end
end

Haml::Filters::Css.module_eval do
  alias_method :orig_render_with_options, :render_with_options

  def render_with_options(*args)
    orig_render_with_options(*args).sub(
      /\A<style([^>]*)>/, "<style\\1 nonce=\"#{Current.content_security_policy_nonce}\">"
    )
  end
end