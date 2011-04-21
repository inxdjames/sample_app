module ApplicationHelper

  def title
    base_title = "Ruby on Rails Tutorial Sample App"
    @title ? "#{base_title} | #{@title}" : base_title
  end

  def logo
    image_tag("logo.png", :alt => "Sample App", :class => "round")
  end
end

