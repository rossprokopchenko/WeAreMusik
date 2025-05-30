module TracksHelper
  def action
    if action_name == "advanced_search"
      :post
    else
      :get
    end
  end

  def results_limit
    # max number of search results to display
    50
  end

  def display_results_header(count)
    if count > results_limit
      "Your first #{results_limit} results out of #{count} total (try narrowing down your search)"
    else
      "Your #{pluralize(count, 'result')}"
    end
  end

  def ms_to_minutes_and_seconds(ms)
    if ms.nil?
      return "Unknown"
    end

    minutes = ms / 60000
    seconds = ms % 60000 / 1000

    minutes_string = "minutes"
    seconds_string = "seconds"
    and_string = "and"

    if minutes == 1
      minutes_string = "minute"
    elsif minutes == 0
      minutes_string = ""
      and_string = ""
    end

    if seconds == 1
      seconds_string = "second"
    elsif seconds == 0
      seconds_string = ""
    end

    return "#{minutes} #{minutes_string} #{and_string} #{seconds} #{seconds_string}"
  end

end
