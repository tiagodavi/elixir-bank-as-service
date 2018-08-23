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
    {
      "data": [
        {"id": 2, "email": "email01@gmail.com", "amount": 10.0},
        {"id": 2, "email": "email02@gmail.com", "amount": 20.0}
      ]
    }
    ```

* **Error Response:**

  * **Code:** 422 Bad Request <br />
    **Content:**
    ```
     {"errors":{"message": "msg"}}
    ```

**[Open Account]**

  * **URL**

    /api/open/:email - Open a new account

  * **Method:**

      `POST`

  * **Success Response:**

    * **Code:** 200 OK <br />
      **Content:**
      ```
       {"id": 1, "email": "email01@gmail.com", "amount": 1000.00}      
      ```

  * **Error Response:**

    * **Code:** 422 Bad Request <br />
      **Content:**
      ```
       {"errors":{"message": "msg"}}
      ```
  * **Example Usage:**

    POST -> `/api/open/email01@gmail.com`

**[Transfer Money]**

  * **URL**

    /api/transfer/:source/:destination/:amount - Transfer amount from source to destination

  * **Method:**

      `PUT`

  * **Success Response:**

    * **Code:** 200 OK <br />
      **Content:**
      ```
       {"source": "email01@gmail.com",  "destination": "email02@gmail.com", "amount": 178.57}      
      ```

  * **Error Response:**

    * **Code:** 422 Bad Request <br />
      **Content:**
      ```
       {"errors":{"message": "msg"}}
      ```
  * **Example Usage:**

    PUT-> `/api/transfer/email01@gmail.com/email02@gmail.com/178.57`


**[Cash Out Money]**

  * **URL**

    /api/cash-out/:source/:amount - Cash out amount from source

  * **Method:**

      `PUT`

  * **Success Response:**

    * **Code:** 200 OK <br />
      **Content:**
      ```
       {"source": "email01@gmail.com", "amount": 178.57}      
      ```

  * **Error Response:**

    * **Code:** 422 Bad Request <br />
      **Content:**
      ```
       {"errors":{"message": "msg"}}
      ```
  * **Example Usage:**

    PUT-> `/api/cash-out/email01@gmail.com/178.57`

#### API's
- /api/banking - Return all accounts
- /api/banking/open/:email - Open a new account
- /api/banking/info/:email - Get account info
- /api/banking/transfer/:source_email/:destination_email/:amount - Transfer Money from source to destination
- /api/banking/cash-out/:email/:amount - Cash Out from Account
- /api/banking/report - Return all Transactions for day (sum), month, year
