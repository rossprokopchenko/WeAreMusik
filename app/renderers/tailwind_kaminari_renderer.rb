class TailwindKaminariRenderer < Kaminari::Helpers::Paginator
  # The #page_tag, #first_page_tag, etc., methods are inherited from Kaminari::Helpers::Paginator
  # and automatically provide access to the current_page object.

  # The `render` method is what Kaminari calls to render the pagination.
  # It typically renders a partial.
  def render
    # Access the current page object directly from the paginated collection.
    # The `options[:template]` is the view context.
    # The `current_page` object provided by Kaminari is an instance of Kaminari::Page.
    # It has methods like `first?`, `last?`, `prev_page`, `next_page`, `offset`, `limit_value`.
    
    # You can pass local variables to the partial that will be rendered.
    options[:template].render partial: 'kaminari/tailwind_kaminari_renderer',
                               locals: {
                                 current_page: @collection.current_page,
                                 total_pages: @collection.total_pages
                               }
  end

  # Override page_tag to customize link appearance
  def page_tag(page)
    tag = page.current? ? :span : :a
    html_attributes = page.current? ? { class: "z-10 bg-indigo-50 border-indigo-500 text-indigo-600 relative inline-flex items-center px-4 py-2 border text-sm font-medium" } : { class: "bg-white border-gray-300 text-gray-500 hover:bg-gray-50 relative inline-flex items-center px-4 py-2 border text-sm font-medium", href: url_for(page: page) }
    
    content_tag(tag, page, html_attributes)
  end

  # You might need to override other helper methods like `first_page_tag`, `prev_page_tag`, etc.,
  # if you want to customize their HTML structure beyond what the partials handle.
  # However, for Tailwind CSS, it's often easier to put the HTML directly in the partials
  # and let the default Kaminari helpers provide the logic.

  # Example of overriding prev_page_tag (if needed, but usually handled by partial)
  # def prev_page_tag
  #   return super unless current_page.first?
  #   tag(:span, raw(t 'views.pagination.previous'), class: "relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white cursor-default")
  # end
end
