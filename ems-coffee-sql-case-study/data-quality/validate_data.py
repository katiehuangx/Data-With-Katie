# 1. Import the Great Expectations library
import great_expectations as gx

# Check version of Great Expectations
# print(gx.__version__)

# 2. Create data context
# Creates context object that is used to manage the configuration and state of Great Expectations
context = gx.get_context()

# Define the connection string for the PostgreSQL database
connection_string = "postgresql+psycopg2://katiehuang@localhost:5432/ems_coffee"

# Add a new data source to the context using the connection string
data_source = context.data_sources.add_postgres(
    name="ems_coffee_postgres",
    connection_string=connection_string,
)

# Print the name of the connected data source to confirm the connection
print("Connected:", data_source.name)


# 3. Define table assets

customer_assets = data_source.add_table_asset(
    table_name="ems_coffee.customers", name ="customers")

menu_assets = data_source.add_table_asset(
    table_name="ems_coffee.menu", name ="menu")

orders_assets = data_source.add_table_asset(
    table_name="ems_coffee.orders", name ="orders")

print("Table assets created:", customer_assets.name, menu_assets.name, orders_assets.name)

# 4. Create an expectation suite — the data quality rules for each table

# Source: https://docs.greatexpectations.io/docs/core/define_expectations/organize_expectation_suites/
# Expectations Gallery: https://greatexpectations.io/expectations/

# Create customers suite
# customer_id not null — every customer row must have an ID
# customer_id unique — no duplicate customer IDs

customers_suite = context.suites.add(gx.ExpectationSuite(name="customers_suite"))
customers_suite.add_expectation(gx.expectations.ExpectColumnValuesToNotBeNull(column="customer_id"))
customers_suite.add_expectation(gx.expectations.ExpectColumnValuesToBeUnique(column="customer_id"))

# Create menu suite
# menu_id not null — every menu row must have an ID
# menu_id unique — no duplicate menu IDs
# price > 0 — no free or negative-priced drinks

menu_suite = context.suites.add(gx.ExpectationSuite(name="menu_suite"))
menu_suite.add_expectation(gx.expectations.ExpectColumnValuesToNotBeNull(column="menu_id"))
menu_suite.add_expectation(gx.expectations.ExpectColumnValuesToBeUnique(column="menu_id"))
menu_suite.add_expectation(gx.expectations.ExpectColumnValuesToBeBetween(column="price", min_value=0))

# Create orders suite
# order_id not null — every order row must have an ID
# order_id unique — no duplicate order IDs
# quantity > 0 — no zero or negative quantity orders
# order_date not null — every order must have a date

orders_suite = context.suites.add(gx.ExpectationSuite(name="orders_suite"))
orders_suite.add_expectation(gx.expectations.ExpectColumnValuesToNotBeNull(column="order_id"))
orders_suite.add_expectation(gx.expectations.ExpectColumnValuesToBeUnique(column="order_id"))
orders_suite.add_expectation(gx.expectations.ExpectColumnValuesToBeGreaterThan(column="quantity", value=0))
orders_suite.add_expectation(gx.expectations.ExpectColumnValuesToNotBeNull(column="order_date"))