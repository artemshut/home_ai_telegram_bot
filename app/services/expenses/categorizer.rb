module Expenses
  class Categorizer
    RULES = [
      [ "Groceries",     %w[groceries supermarket market food shop produce bakery] ],
      [ "Dining",        %w[restaurant cafe coffee lunch dinner breakfast bar takeaway pizza] ],
      [ "Transport",     %w[gas fuel petrol taxi uber bus train metro parking toll] ],
      [ "Utilities",     %w[electricity water internet phone mobile bill utility heating] ],
      [ "Health",        %w[pharmacy doctor medicine hospital health dentist gym sport] ],
      [ "Entertainment", %w[cinema movie concert ticket museum book game streaming] ],
      [ "Clothing",      %w[clothes shoes clothing fashion] ]
    ].freeze

    def call(description)
      lower = description.to_s.downcase
      RULES.each do |category, keywords|
        return category if keywords.any? { |kw| lower.include?(kw) }
      end
      "Other"
    end
  end
end
