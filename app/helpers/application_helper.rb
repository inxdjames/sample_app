module ApplicationHelper
  def title
    base_title = "Ruby on Rails Tutorial Sample App"
    @title ? "#{base_title} | #{@title}" : base_title
  end
end
