class TailwindKaminariRenderer < Kaminari::Helpers::Paginator
  def to_s
    puts "Renderer Being used -----------------------------"
  end

  def render
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
end
