# 🚀 smart-mock  "Intelligent API Mocking Tool"
smart-mock is an advanced, intelligent API mocking tool that simulates real backend behaviour. It supports data validation, dynamic flows, and conditional responses, making it easy to test your apps even before the backend is ready.

---

## 📦 Features

- 🧠 Contract-based API mocking with intelligent validation
- ⚙️ Dynamic and default response simulation
- 🧪 Support for multiple flows: success, error, edge cases
- 🛡️ Validates incoming request bodies
- 🔌 Easy RESTful API to deploy and manage mocks
- 🧾 OpenAPI support (coming soon!)

---

## 🌐 Exposed APIs

### `POST /deployContract`

Deploys a mock contract with expected request and default response.

**URL:**  
`http://localhost:8080/deployContract`

**Request Headers:**
```http
Content-Type: application/json
```

**Request Body:**
```json
{
  "endpoint": "login",
  "request": {
    "body": {
      "username": "Sandeep",
      "password": "smarkmock",
      "age": 25
    }
  },
  "response": {
    "body": {
      "token": "mocked-token-123"
    }
  }
}
```

**Contract flat sturcture mapped with data types in Response:**
```json
{
    "response": {
        "body.username": "String",
        "body.password": "String",
        "body.age": "Integer"
    }
}
```

### `POST /deployScenario`

Deploys a response mapped with expected request values of an endpoint.

**URL:**  
`http://localhost:8080/deployScenario`

**Request Headers:**
```http
Content-Type: application/json
```

**Request Body:**
```json
{
  "endpoint": "login",
  "request": {
    "body": {
      "age": 20,
    }
  },
  "response": {
    "body": {
      "token": "mocked-token-1234"
    }
  }
}
```

**Success Response:**
```json
{
  "response": "'Success' Scenario deployed for testing"
}
```

### `POST /service/<endpoint>`

Validates the request structure & data types of an endpoint against the configured contract.

Returns the response mapped to the expected request values if a matching scenario is configured. 
Otherwise, it falls back to the default response defined for the endpoint's contract.

**URL:**  
`http://localhost:8080/service/login`

**Request Headers:**
```http
Content-Type: application/json
```

**Request Body:**
```json
{
    "body": {
      "age": 20,
    }
}
```

**Success Response:**
```json
{
    "body": {
      "token": "mocked-token-1234"
    }
}
```

### `GET /fetchContracts or /fetchContracts/<endpoint>`

Fetches all contracts or contract of an endpoint.

**URL:**  
`http://localhost:8080/fetchContracts` or `http://localhost:8080/fetchContracts/login`

**Request Headers:**
```http
Content-Type: application/json
```

**Returns the contracts deployed**
```json
{
    "contracts": [
        {
            "request": {
                "body.username": "String",
                "body.password": "String",
                "body.age": "Integer"
            },
            "endpoint": "setPreferences",
            "response": {
                "body": {
                    "token": "mocked-token-123"
                }
            }
        }
    ]
}
```

### `GET /fetchScenarios or /fetchScenarios/<endpoint>`

Fetches all scenarios or scenarios of a given endpoint.

**URL:**  
`http://localhost:8080/fetchScenarios` or `http://localhost:8080/fetchScenarios/login`

**Request Headers:**
```http
Content-Type: application/json
```

**Returns the scenarios deployed**
```json
{
    "scenarios": [
        {
            "request": {
                "body": {
                    "age": 20,
                }
            },
            "endpoint": "login",
            "response": {
                "body": {
                    "token": "mocked-token-1234"
                }
            }
        }
    ]
}
```

---

## ▶️ How to Run

### 🔸 Using JAR File

```bash
java -jar smart-mock.jar
```

The mock server will start at:  
**http://localhost:8080**

---

## 📁 Directory Structure

```
smart-mock/
├── smart-mock.jar
├── api_contracts.json
├── api_testCases.json
```

---

## 👥 Contributing

I’d love your help to improve smart-mock!  
Feel free to report issues or suggest features.

---

## 📜 License

This project is licensed under the **MIT License**.

---

## 📫 Contact

Questions, feedback, or cool ideas?  
Open an issue or reach out at [venu.medidi@gmail.com].

---
