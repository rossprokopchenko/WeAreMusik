module TracksHelper
  def month_to_str(month)
    case month
      when 1 then "January"
      when 2 then "February"
      when 3 then "March"
      when 4 then "April"
      when 5 then "May"
      when 6 then "June"
      when 7 then "July"
      when 8 then "August"
      when 9 then "September"
      when 10 then "October"
      when 11 then "November"
      when 12 then "December"
      else "Unknown Month"
    end
  end

  def label_str(displayable_release_labels)
    output = ""

    displayable_release_labels.each do |label|
      label_name = label.label.name
      output += label_name
      output += " • " unless label == displayable_release_labels.last
    end

    return output
  end

end
