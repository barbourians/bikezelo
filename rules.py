import great_expectations as gx


def get_rules(suite):
    """
    Add your Great Expectations rules here.
    The suite is re-built every validation cycle so changes take effect immediately.

    Available expectations:
    -----------------------------------------------------------------------
    Not null check:
        suite.add_expectation(
            gx.expectations.ExpectColumnValuesToNotBeNull(column="customer_id")
        )

    Value range check:
        suite.add_expectation(
            gx.expectations.ExpectColumnValuesToBeBetween(
                column="order_amount",
                min_value=0,
                max_value=999.99
            )
        )

    Valid values check:
        suite.add_expectation(
            gx.expectations.ExpectColumnValuesToBeInSet(
                column="status",
                value_set=["NEW", "PAID", "SHIPPED", "REFUNDED"]
            )
        )
    -----------------------------------------------------------------------
    Add your rules below this line:
    """

    # Level A - uncomment to catch missing customer IDs
    suite.add_expectation(
        gx.expectations.ExpectColumnValuesToNotBeNull(column="customer_id")
    )

    # Level B - uncomment to catch order amounts outside range
    suite.add_expectation(
        gx.expectations.ExpectColumnValuesToBeBetween(
            column="order_amount",
            min_value=0,
            max_value=999.99
        )
    )

    # Level C - add your own rule here
    #

    return suite

