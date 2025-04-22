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
  "endpoint": "/api/login",
  "request": {
    "body": {
      "username": "string",
      "password": "string"
    }
  },
  "response": {
    "status": 200,
    "body": {
      "token": "mocked-token-123"
    }
  }
}
```

**Success Response:**
```json
{
  "status": "success",
  "message": "Contract deployed successfully"
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

## 📁 Directory Structure (Optional Setup)

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
```

---
