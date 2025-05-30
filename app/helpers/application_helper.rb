module ApplicationHelper
  def nav_link_class(target_controller)
    if @current_page == target_controller
      "text-blue-500 md:p-0 text-lg"
    else
      "text-gray-900 hover:bg-gray-100 md:hover:text-blue-700 md:p-0 dark:text-white md:dark:hover:text-blue-500 dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent"
    end
  end
end
