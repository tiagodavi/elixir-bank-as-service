**Banking API**
----
  Basic Auth is required for all requests

  - ***username: backoffice***
  - ***password: backoffice***

* **[Get all accounts]**

  /api - Return all accounts

* **Method:**

  `GET`

* **Success Response:**

  * **Code:** 200 OK <br />
    **Content:**
    ```
    [
      {"id": 2, "number": "16ec49e5", "amount": "R$10,00"},
      {"id": 2, "number": "17ec49e5", "amount": "R$10,00"}
    ]
    ```

* **Error Response:**

  * **Code:** 422 Bad Request <br />
    **Content:**
    ```
     {"errors": "msg"}
    ```

* **[Get account statements]**

  /api/statement/:number - Return account's statements

* **Method:**

  `GET`

* **Success Response:**

  * **Code:** 200 OK <br />
    **Content:**
    ```
      [%{"amount" => "R$129,31", "balance" => "R$870,69", "operation" => "cash out"}]
    ```

* **Error Response:**

  * **Code:** 422 Bad Request <br />
    **Content:**
    ```
     {"errors": "msg"}
    ```

* **Example Usage:**

  GET -> `/api/statement/16ec49e5`

* **[Get account balance]**

  /api/balance/:number - Return account balance

* **Method:**

  `GET`

* **Success Response:**

  * **Code:** 200 OK <br />
    **Content:**
    ```
      {"id": 1, "number": "16ec49e5", "amount": "R$1.000,00"}
    ```

* **Error Response:**

  * **Code:** 422 Bad Request <br />
    **Content:**
    ```
     {"errors": "msg"}
    ```

* **Example Usage:**

  GET -> `/api/balance/16ec49e5`

**[Open Account]**

  * **URL**

    /api/open - Open a new account

  * **Method:**

      `POST`

  * **Success Response:**

    * **Code:** 200 OK <br />
      **Content:**
      ```
       {"id": 1, "number": "16ec49e5", "amount": "R$1.000,00"}      
      ```

  * **Error Response:**

    * **Code:** 422 Bad Request <br />
      **Content:**
      ```
        {"errors": "msg"}
      ```
  * **Example Usage:**

    POST -> `/api/open`

**[Transfer Money]**

  * **URL**

    /api/transfer/:source/:destination/:amount - Transfer amount from source to destination

  * **Method:**

      `POST`

  * **Success Response:**

    * **Code:** 200 OK <br />
      **Content:**
      ```
       {"source": "16ec49e5",  "destination": "17ec49e5", "amount": "R$178,57", "operation": 1}      
      ```

  * **Error Response:**

    * **Code:** 422 Bad Request <br />
      **Content:**
      ```
        {"errors": "msg"}
      ```
  * **Example Usage:**

    POST -> `/api/transfer/16ec49e5/17ec49e5/17857`


**[Cash Out Money]**

  * **URL**

    /api/cash-out/:source/:amount - Cash out amount from source

  * **Method:**

      `POST`

  * **Success Response:**

    * **Code:** 200 OK <br />
      **Content:**
      ```
       {"source": "17ec49e5", "amount": "R$178,57", "operation": 2}      
      ```

  * **Error Response:**

    * **Code:** 422 Bad Request <br />
      **Content:**
      ```
        {"errors": "msg"}
      ```
  * **Example Usage:**

    POST -> `/api/cash-out/17ec49e5/17857`

**[Report]**

  * **URL**

    /api/report/:start_date/:end_date - Generate a report from start_date to end_date

  * **Method:**

      `GET`

  * **Success Response:**

    * **Code:** 200 OK <br />
      **Content:**
      ```
      {
         "data": {
             "total": "R$1.000,00"
             "report": [
                 {
                     "source": "16ec49e5",
                     "destination": "17ec49e5",
                     "amount": "R$75,00",
                     "operation": 1
                 },
                 {
                     "source": "16ec49e5",
                     "amount": "R$75,00",
                     "operation": 2
                 },
                 {
                     "source": "16ec49e5",
                     "amount": "R$800,00",
                     "operation": 2
                 },
                 {
                     "source": "16ec49e5",
                     "amount": "R$50,00",
                     "operation": 2
                 }
             ]
         }
      }   
      ```

  * **Error Response:**

    * **Code:** 422 Bad Request <br />
      **Content:**
      ```
        {"errors": "msg"}
      ```
  * **Example Usage:**

    GET -> `/api/report/2018-08-01/2018-08-23`
