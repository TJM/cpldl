class HomeController < ApplicationController

  def index
    english_id = Language.find_by_name("English").id || 1
    spanish_id = Language.find_by_name("Spanish").id || 2
    case I18n.locale
    when :es
      if request.subdomain == "www"
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: spanish_id, display_on_dl: true).where_exists(:organization, subdomain: request.subdomain)
      else
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: spanish_id).where_exists(:organization, subdomain: request.subdomain)
      end
    else
      if request.subdomain == "www"
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: english_id, display_on_dl: true).where_exists(:organization, subdomain: request.subdomain)
      else
        @courses = Course.includes(:lessons).where(pub_status: "P", language_id: english_id).where_exists(:organization, subdomain: request.subdomain)
      end
    end
  end

  def language_toggle
    session[:locale] = params["lang"]
    redirect_to :back
  end
end
