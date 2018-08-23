**Banking API**
----
  Basic Auth is required for all requests

  - ***username: backoffice***
  - ***password: backoffice***

* **URL**

  /api - Return all accounts

* **Method:**

  `GET`

* **Success Response:**

  * **Code:** 200 OK <br />
    **Content:**
    ```
    [
      {"email": "email01@gmail.com", amount: 10.0},
      {"email": "email02@gmail.com", amount: 20.0}
    ]
    ```

* **Error Response:**

  * **Code:** 422 Bad Request <br />
    **Content:**
    ```
     {"errors":{"message":{"field":["message"]}}}
    ```


#### API's
- /api/banking - Return all accounts
- /api/banking/open/:email - Open a new account
- /api/banking/info/:email - Get account info
- /api/banking/transfer/:source_email/:destination_email/:amount - Transfer Money from source to destination
- /api/banking/cash-out/:email/:amount - Cash Out from Account
- /api/banking/report - Return all Transactions for day (sum), month, year
