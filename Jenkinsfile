pipeline {
  agent {
    node {
      label 'local'
    }

  }
  stages {
    stage('Setup') {
      steps {
        sh 'make cli.build'
        sh 'make volume-init'
        sh 'make cli.up'
      }
    }
    stage('Test') {
      steps {
        sh 'make cli.test'
      }
    }
    stage('Publish') {
      steps {
        sh 'make gemspec'
        sh 'make credspec'
      }
    }
  }
  post {
    always {
      sh 'make teardown'

    }

  }
}