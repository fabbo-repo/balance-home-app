from balance.models import AnnualBalance, MonthlyBalance
from coin.currency_converter_integration import convert_or_fetch
from revenue.models import Revenue


def check_dates_and_update_date_balances(
        instance,
        converted_quantity,
        converted_new_quantity=None,
        new_date=None
    ):
    is_revenue = type(instance) == Revenue
    month = instance.date.month
    year = instance.date.year
    owner = instance.owner
    if new_date:
        if year != new_date.year or month != new_date.month:
            # Remove quantity for old date_balances
            update_or_create_annual_balance(
                - converted_quantity, owner, year, is_revenue
            )
            update_or_create_monthly_balance(
                - converted_quantity, owner, year, month,
                is_revenue
            )
            # Add quantity for new date_balances
            update_or_create_annual_balance(
                converted_new_quantity if converted_new_quantity \
                else converted_quantity,
                owner, new_date.year, is_revenue
            )
            update_or_create_monthly_balance(
                converted_new_quantity if converted_new_quantity \
                else converted_quantity, owner, 
                new_date.year, new_date.month,
                is_revenue
            )
            return
        else:
            # In case date does not change and there is no new quantity
            if not converted_new_quantity: return
    # In case there is no new date (month and year), 
    # only quantity should be calculated
    update_or_create_annual_balance(
        converted_new_quantity - converted_quantity,
        owner, year, is_revenue
    )
    update_or_create_monthly_balance(
        converted_new_quantity - converted_quantity,
        owner, year, month, is_revenue
    )

def update_or_create_annual_balance(converted_quantity, owner, 
    year, is_revenue):
    """
    Create or update an annual_balance from an expense or revenue, 
    if it is revenue the quantity is increased, otherwise (revenue) 
    it is decreased
    """
    annual_balance, created = AnnualBalance.objects.get_or_create(
        owner = owner,
        year = year
    )
    annual_balance.coin_type = owner.pref_coin_type
    # If an annual_balance already existed, its gross_quantity 
    # must be converted
    if not created:
        annual_balance.gross_quantity = convert_or_fetch(
            annual_balance.coin_type, 
            owner.pref_coin_type,
            annual_balance.gross_quantity
        )
    # Update extra fields
    if (is_revenue): annual_balance.gross_quantity += converted_quantity
    else: annual_balance.gross_quantity -= converted_quantity
    if created: annual_balance.expected_quantity = owner.expected_annual_balance
    annual_balance.save()


def update_or_create_monthly_balance(converted_quantity, owner, 
    year, month, is_revenue):
    """
    Create or update a monthly_balance from an expense or revenue, 
    if it is revenue the quantity is increased, otherwise (revenue) 
    it is decreased
    """
    monthly_balance, created = MonthlyBalance.objects.get_or_create(
        owner = owner,
        year = year,
        month = month
    )
    monthly_balance.coin_type = owner.pref_coin_type
    # If a monthly_balance already existed, its gross_quantity 
    # must be converted
    if not created:
        monthly_balance.gross_quantity = convert_or_fetch(
            monthly_balance.coin_type, 
            owner.pref_coin_type,
            monthly_balance.gross_quantity
        )
    # Update extra fields
    if (is_revenue): monthly_balance.gross_quantity += converted_quantity
    else: monthly_balance.gross_quantity -= converted_quantity
    if created: monthly_balance.expected_quantity = owner.expected_monthly_balance
    monthly_balance.save()