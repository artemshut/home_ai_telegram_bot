class Admin::WeeklyMenusController < Admin::BaseController
  def index
    @weekly_menus = WeeklyMenu.includes(:household, meals: :dish)
                              .order(week_start_date: :desc)
                              .limit(50)
  end

  def show
    @weekly_menu = WeeklyMenu.includes(:household, meals: :dish).find(params[:id])
  end
end
