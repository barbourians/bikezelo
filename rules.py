"""
Great Expectation rules

orders.csv
row_id,timestamp,customer_id,order_amount,status
1,2026-03-05T23:54:31,CUST2558,194.31,PAID
2,2026-03-05T23:54:33,CUST9681,273.35,SHIPPED
...
"""
import great_expectations as gx


def get_rules(suite):
    """
    Add your Great Expectations rules here.
    The suite is re-built every validation cycle so changes take effect immediately.

    Available expectations:
    -----------------------------------------------------------------------
    # Not null check:
    suite.add_expectation(
        gx.expectations.ExpectColumnValuesToNotBeNull(column="customer_id")
    )

    # Value range check:
    suite.add_expectation(
        gx.expectations.ExpectColumnValuesToBeBetween(
            column="order_amount",
            min_value=0,
            max_value=999.99
        )
    )

    # Valid values check:
    suite.add_expectation(
        gx.expectations.ExpectColumnValuesToBeInSet(
            column="status",
            value_set=["NEW", "PAID", "SHIPPED", "REFUNDED"]
        )
    )
    -----------------------------------------------------------------------
    Add your rules below this line:
    """

    # Step 1 - Catch missing customer IDs
    #      a) uncomment the code below (3 lines)
    ##################################
    #suite.add_expectation(
    #    gx.expectations.ExpectColumnValuesToNotBeNull(column="customer_id")
    #)

    # Step 2 - Catch order amounts outside range
    #      a) uncomment the code below (7 lines)
    #      b) change the min & max values (if you want to)
    ##################################
    
    #suite.add_expectation(
    #    gx.expectations.ExpectColumnValuesToBeBetween(
    #        column="order_amount",
    #        min_value=0,
    #        max_value=999.99
    #    )
    #)

    
    # Step 3 - Valid values check:
    #      a) copy the code from above
    #      b) change the values if you want to
    ##################################

    
    # Step 4 - Your own rules
    #      a) change bin/simulate.sh
    #      b) then add a custom rule here
    ##################################


    return suite

