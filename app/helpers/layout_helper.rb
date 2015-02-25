module LayoutHelper
  def active_org(org)
    (org.id == current_organization.id ? 'active' : '')
  end

  def currency_title(current_organization)
    Dictionaries.currencies.map { |curr| money_with_symbol(current_organization.bank_accounts.total_balance(curr)) }.join(" | ")
  end
end
