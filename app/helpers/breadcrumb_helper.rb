module BreadcrumbHelper
  def breadcrumb_link_to(title, url, *args)
    content_tag(:li,
                title,
                class: 'govuk-breadcrumbs__list-item') do
      link_to(title, url, *args, class: 'govuk-breadcrumbs__link')
    end.html_safe
  end

  def breadcrumb_current(title = nil, &blk)
    content_tag(:li,
                title,
                class: 'govuk-breadcrumbs__list-item', 'aria-current' => 'page') do
      title.nil? && communal_area_given? ? content_tag(:span, &blk) : content_tag(:span, title)
    end
  end
end
