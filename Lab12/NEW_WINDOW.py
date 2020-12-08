import pyodbc

connection = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};'
                            'SERVER=datascience123.database.windows.net;'
                            'DATABASE=datascience;UID=svetlana;PWD=DataScience123')
while True:

    print("(Enter 'X' to exit)")
    print("Task number (1A-C, 2A-C):")
    num = input()

    if num.upper() == 'X':
        break

    cursor = connection.cursor()

    # 1A. Rank your sales persons by number of clients,
    # report should include rank, sales person id and client number in descending order.
    if num.upper() == "1A":
        cursor.execute("""
        SELECT rank() OVER (ORDER BY count(c.CustomerID) DESC) AS Rank, 
        c.SalesPerson, count(c.CustomerID) AS Customers 
        FROM SalesLT.Customer c 
        GROUP BY c.SalesPerson
        """)

    # 1B. Rank your sales persons by number of sales,
    # your report should include all sales persons with id, dense rank and number of sales in descending order.
    elif num.upper() == "1B":
        cursor.execute("""
        SELECT dense_rank() OVER (ORDER BY count(h.SalesOrderID) DESC) AS Rank,
        c.SalesPerson, count(h.SalesOrderID) AS Orders
        FROM SalesLT.Customer c 
        LEFT JOIN SalesLT.SalesOrderHeader h
        ON c.CustomerID = h.CustomerID
        GROUP BY c.SalesPerson    
        """)

    # 1C. Rank your sales person by income from sales,
    # your report should include all sales persons with id, rank and income in descending order.
    elif num.upper() == "1C":
        cursor.execute("""
        SELECT rank() OVER (ORDER BY sum(h.SubTotal) DESC) AS Rank,
        c.SalesPerson, sum(h.SubTotal) AS Income 
        FROM SalesLT.Customer c 
        LEFT JOIN SalesLT.SalesOrderHeader h
        ON c.CustomerID = h.CustomerID
        GROUP BY c.SalesPerson 
        """)

    # 2A. Rank regions / states in the country by number of customers (use main office address),
    # report include country, state/region, number of customers and percent rank ordered by country and number of clients.
    # In case of equality in client numbers order region or states alphabetically.
    elif num.upper() == "2A":
        cursor.execute("""
        SELECT address.StateProvince, count(c.CustomerID) as Customers, percent_rank()
        OVER (PARTITION BY address.CountryRegion ORDER BY count(c.CustomerID) DESC, address.StateProvince) AS "Percent rank"
        FROM SalesLT.CustomerAddress c
        INNER JOIN SalesLT.Address address
        ON c.AddressID = address.AddressID
        GROUP BY address.CountryRegion, address.StateProvince
        """)

    # 2B. Include in previous report customers without information about address.
    # Use dense rank instead of percent rank in that report.
    elif num.upper() == "2B":
        cursor.execute("""
        SELECT dense_rank() OVER (PARTITION BY address.CountryRegion ORDER BY count(c.CustomerID) DESC, address.StateProvince) AS Rank,
        address.StateProvince, count(c.CustomerID) as Customers
        FROM SalesLT.Customer c
        LEFT JOIN SalesLT.CustomerAddress ca
        ON c.CustomerID = ca.CustomerID
        LEFT JOIN SalesLT.Address address
        ON ca.AddressID = address.AddressID
        GROUP BY address.CountryRegion, address.StateProvince
        """)

    # 2C. Rank cities in the country by number of customers (use main office address),
    # your report should include country, state or region, city,  number of clients,
    # rank and difference in number of client with previous position in by country ranking.
    # Order your report by country name (alphabetically), number of clients (descending) and city name (alphabetically).
    elif num.upper() == "2C":
        cursor.execute("""
        SELECT rank() OVER (PARTITION BY address.StateProvince 
        ORDER BY count(c.CustomerID) DESC, address.StateProvince, address.City) AS Rank,
        address.StateProvince, address.City, count(c.CustomerID) as Customers, 
        lag(count(c.CustomerID)) 
        OVER (PARTITION BY address.StateProvince 
        ORDER BY count(c.CustomerID) DESC, address.StateProvince, address.City) - count(c.CustomerID) as Difference     
        FROM SalesLT.CustomerAddress c
        INNER JOIN SalesLT.Address address
        ON c.AddressID = address.AddressID
        GROUP BY address.StateProvince, address.City
        ORDER BY 2
        """)

    else:
        print("Wrong task number, try again")
        continue

    rows = cursor.fetchall()

    for row in rows:
        print(row)

connection.close()