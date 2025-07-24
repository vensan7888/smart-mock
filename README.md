# 🚀 smart-mock  "Smart API Mocking Tool"
smart-mock is an advanced, smart API mocking tool that simulates real backend behaviour. It supports data validation, dynamic flows, and conditional responses, making it easy to test your apps even before the backend is ready.

---

# SmartMock 2.0

## ✨ What's New in 2.0

### ✅ OpenAPI Specification Support
SmartMock supported scripts now reads from **OpenAPI YAML files** to auto-generate mock endpoints and response structures — enabling **contract-first development**.

---

### ✅ Automated Mock Deployment Scripts

SmartMock 2.0 supports **three flexible ways to trigger contract updates to your local or remote mock server**:

#### 🧩 1. Jenkins Pipeline Script
- Integrate directly with your CI/CD pipeline.
- Automatically deploy updated OpenAPI contracts whenever changes are committed to the repository.

#### 💻 2. Local Trigger Using Remote Repo
- Trigger SmartMock from your machine by **pointing to a GitHub/GitLab repo**.
- Useful for testing contract changes before deployment.

#### 📁 3. Local Trigger Using Local Directory
- Trigger SmartMock by pointing to a **local source code directory**.
- Fastest way to test contract updates in real-time while developing.

---

## 🧰 Response Configuration at Contract Level
- Define response structure **alongside the contract**.
- No need to hard-code anything — configuration-driven.

---

## ✅ Validations on Response Structure
- During scenario-based testing, SmartMock **validates the structure of incoming request & response**.
- Helps detect contract mismatches early in the development cycle.

---

## 🧪 Use Cases

- Frontend testing without backend dependency.
- API design-first workflows.
- CI/CD-driven contract testing.
- Local development simulations for microservices.

---

## 📂 Folder Structure

```
smartmock-2.0/
├── smart-mock.jar
├── scripts/
│   ├── jenkinsDeployMock.sh
│   ├── deployMockFromRepo.sh
│   └── deployMockFromDirectory.sh
└── README.md
```
---

## 🚀 Getting Started

### 1. Install 'yq'
``` sh
`brew install yq`
```

### 2. Clone the repository:
```sh
git clone https://github.com/vensan7888/smart-mock.git
cd smart-mock
```

### 3. Set Up Jenkins Trigger
Integrate 
`sh scripts/jenkinsDeployMock.sh https://your-smarmock-server` deploys only changed yaml files since last commit.
`OR`
`sh scripts/jenkinsDeployMock.sh https://your-smarmock-server y` deploys all yaml files of repo, useful for first time integration with existing repository.

into your Jenkinsfile to auto-deploy updated contracts.

### 4. Run on Remote repository Trigger
```sh
`sh scripts/deployMockFromRepo.sh https://github.com/username/yourProject.git yourBranch https://your-smarmock-server` deploys only changed yaml files since last commit.
```
```sh
`sh scripts/deployMockFromRepo.sh https://github.com/username/yourProject.git yourBranch https://your-smarmock-server` deploys all yaml files of remote repo, useful for first time integration with existing repository.
```

### 5. Run Local Trigger
`sh scripts/deployMockFromDirectory.sh /path/to/your/source/code https://your-smarmock-server` deploys all yaml files of directory, useful when the changes of backend are not yet merged.

---


---

# SmartMock 1.0
---

## 📦 Features

- 🧠 Contract-based API mocking with intelligent validation
- ⚙️ Dynamic and default response simulation
- 🧪 Support for multiple flows: success, error, edge cases
- 🛡️ Validates incoming request bodies
- 🔌 Easy RESTful API to deploy and manage mocks

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

## 📣 Contributing

We welcome PRs, ideas, and feedback! Let’s make API mocking smarter together.

---

## 📃 License

MIT License – Use freely and contribute to grow the ecosystem.

---

## 📫 Contact

Questions, feedback, or cool ideas?  
Open an issue or reach out at [venu.medidi@gmail.com].

---
