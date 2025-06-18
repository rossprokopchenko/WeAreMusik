module ApplicationHelper
  def nav_link_class(target_controller)
    base = "text-lg md:p-0 transition-all duration-150"
    if @current_page == target_controller
      "#{base} text-blue-500 text-lg font-semibold"
    else
      "#{base} text-gray-900 hover:bg-gray-100 md:hover:text-blue-700 dark:text-white md:dark:hover:text-blue-500 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent"
    end
  end
end
