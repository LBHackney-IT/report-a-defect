module NotifyViewHelper
  def notify_link(url, text = url)
    "[#{text}](#{url})"
  end

  def accept_defect_ownership_link(token)
    link_text = I18n.t('email.defect.forward.accept.link')
    notify_link(defect_accept_url(token), link_text)
  end
end
