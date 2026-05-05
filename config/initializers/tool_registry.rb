Rails.application.config.after_initialize do
  [
    Ai::Tools::AddDishTool,
    Ai::Tools::ListDishesTool,
    Ai::Tools::PlanWeeklyMenuTool,
    Ai::Tools::CreateShoppingListTool,
    Ai::Tools::AddShoppingItemTool,
    Ai::Tools::LogExpenseTool,
    Ai::Tools::SummarizeExpensesTool,
    Ai::Tools::ListExpenseCategoriesTool,
    Ai::Tools::CreateCalendarEventTool,
    Ai::Tools::ListCalendarEventsTool,
    Ai::Tools::TranslateTool,
    Ai::Tools::CreateNoteTool,
    Ai::Tools::ListNotesTool,
    Ai::Tools::EditNoteTool,
    Ai::Tools::DeleteNoteTool
  ].each { |tool| Ai::ToolRegistry.register(tool) }
end
