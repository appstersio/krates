pipeline {
  agent any

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
      when {
        branch 'master'
        buildingTag()
        expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
      }
      steps {
        sh 'make cli.gemspec'
        sh 'make cli.credspec'
        sh 'make cli.publish'
      }
    }
  }
  post {
    always {
      sh 'make teardown'
    }
  }
}