pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        echo 'Building...'
        sh ./checkDeployContractsInMock.sh https://github.com/vensan7888/smart-mock.git http://localhost:8080
      }
    }
  }
}
