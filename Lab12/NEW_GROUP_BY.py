import pyodbc

connection = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'
                            'SERVER=datascience123.database.windows.net;'
                            'DATABASE=datascience;UID=svetlana;PWD=DataScience123')

cursor = connection.cursor()

while True:

    print("(Enter 'X' to exit)")
    print("Task number (A1-2, B-E):")
    num = input()

    if num.upper() == 'X':
        break

    # A1. Report about income from sales by product, client and sales person.
    elif num.upper() == "A1":
        cursor.execute("""
        SELECT c.CustomerID, c.SalesPerson, d.ProductID, sum(d.LineTotal)
        FROM SalesLT.Customer c
        INNER JOIN  SalesLT.SalesOrderHeader h
        ON c.CustomerID = h.CustomerID
        INNER JOIN SalesLT.SalesOrderDetail d
        ON h.SalesOrderID = d.SalesOrderID
        GROUP BY CUBE (c.CustomerID, c.SalesPerson, d.ProductID)
        ORDER BY 1,2,3
        """)

    # A2. Version with zero values
    # Все покупатели и продукты, не зависимо от того, есть ли они в списке заказов
    elif num.upper() == "A2":
        cursor.execute("""
        SELECT p.ProductID, c.CustomerID, c.SalesPerson, sum(d.LineTotal) as Income
        FROM SalesLT.Customer c
        FULL JOIN  SalesLT.SalesOrderHeader h
        ON c.CustomerID = h.CustomerID
        FULL JOIN SalesLT.SalesOrderDetail d
        ON h.SalesOrderID = d.SalesOrderID
        FULL JOIN SalesLT.Product p
        ON d.ProductID = p.ProductID
        GROUP BY CUBE (p.ProductID, c.CustomerID, c.SalesPerson)
        ORDER BY 1,2,3
        """)

    # B. Report about income from sales by product, client and country (region) for billing, shipping and client residency.
    # доставка и адрес покупателя - как далеко от дома заказ и как много тратят на заказы не для себя
    # счёт и адрес покупателя - кто платит за заказ (сам/компания/спонсор), как много
    elif num.upper() == "B":
        cursor.execute("""
        SELECT d.ProductID, c.CustomerID,
        shipping.CountryRegion as Shipping, billing.CountryRegion as Billing,
        caddress.CountryRegion as "Customer addres", sum(d.LineTotal) as Income
        FROM SalesLT.Customer c
        INNER JOIN SalesLT.CustomerAddress ca
        ON c.CustomerID = ca.CustomerID
        INNER JOIN SalesLT.Address caddress
        ON ca.AddressID = caddress.AddressID
        INNER JOIN  SalesLT.SalesOrderHeader h
        ON c.CustomerID = h.CustomerID
        INNER JOIN SalesLT.SalesOrderDetail d
        ON h.SalesOrderID = d.SalesOrderID
        INNER JOIN SalesLT.Address shipping
        ON h.ShipToAddressID = shipping.AddressID
        INNER JOIN SalesLT.Address billing
        ON h.BillToAddressID = billing.AddressID
        GROUP BY GROUPING SETS
        ((d.ProductID, c.CustomerID, shipping.CountryRegion, caddress.CountryRegion),
        (d.ProductID, c.CustomerID, billing.CountryRegion, caddress.CountryRegion))
        ORDER BY 1,2,3,4,5
        """)

    # C.Report about income from sales and provided discounts
    # by location in form of hierarchy city>state/province>country/region.
    # Почтовый индекс чтобы разделить большие города по районам
    elif num.upper() == "C":
        cursor.execute("""
        SELECT shipping.CountryRegion, shipping.StateProvince, shipping.City, shipping.PostalCode,
        sum(d.LineTotal) as Income, sum(d.OrderQty * d.UnitPrice - d.LineTotal) as Discount
        FROM SalesLT.SalesOrderDetail d
        INNER JOIN SalesLT.SalesOrderHeader h
        ON d.SalesOrderID = h.SalesOrderID
        INNER JOIN SalesLT.Address shipping
        ON h.ShipToAddressID = shipping.AddressID
        GROUP BY ROLLUP (shipping.CountryRegion, shipping.StateProvince, (shipping.City, shipping.PostalCode))
        """)

    # D. Report about income from sales and provided discounts by product and
    # hierarchy of product categories (high level category-> next level category->...->low level category->product).
    # Отчёт о доходах и скидках по высшим категориям
    elif num.upper() == "D":
        cursor.execute("""
            SELECT d.ProductID, cat.ParentProductCategoryID AS "Parent Category",
            sum(d.LineTotal) as Income, sum(d.OrderQty * d.UnitPrice - d.LineTotal) as Discount
            FROM SalesLT.SalesOrderDetail d
            INNER JOIN SalesLT.Product p
            ON d.ProductID = p.ProductID
            INNER JOIN SalesLT.ProductCategory cat
            ON p.ProductCategoryID = cat.ProductCategoryID
            GROUP BY ROLLUP (cat.ParentProductCategoryID, d.ProductID)
            """)

    # E. Create integral report on number of product sales by product, client, sales person and hierarchy of regions.
    # Отчёт по конкретному продукту - сколько купил клиент, куда заказал (ROLLUP и CUBE вместе)
    # Для каждой группе из CUBE проводится группировка ROLLUP
    elif num.upper() == "E":
        cursor.execute("""
        SELECT d.ProductID, c.CustomerID, c.SalesPerson,
        shipping.CountryRegion, shipping.StateProvince, shipping.City,
        sum(d.OrderQty) AS Quantity
        FROM SalesLT.Customer c 
        INNER JOIN SalesLT.SalesOrderHeader h
        ON c.CustomerID = h.CustomerID
        INNER JOIN SalesLT.SalesOrderDetail d
        ON h.SalesOrderID = d.SalesOrderID
        INNER JOIN SalesLT.Address shipping
        ON h.ShipToAddressID = shipping.AddressID
        GROUP BY CUBE (d.ProductID, c.CustomerID, c.SalesPerson),
        ROLLUP (shipping.CountryRegion, shipping.StateProvince, shipping.City)    
        ORDER BY 1,2,4,3,5,6
        """)

    else:
        print("Wrong task number, try again")
        continue

    rows = cursor.fetchall()

    for row in rows:
        print(row)

connection.close()
