Household.find_or_create_by!(name: "Home")

ExpenseCategory::DEFAULT_NAMES.each do |name|
  ExpenseCategory.find_or_create_by!(name: name)
end
