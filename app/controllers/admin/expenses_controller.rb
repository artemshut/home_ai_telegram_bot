class Admin::ExpensesController < Admin::BaseController
  def index
    @expenses = Expense.includes(:expense_category, :telegram_user, :household)
                       .order(spent_on: :desc, created_at: :desc)
                       .limit(100)
  end
end
