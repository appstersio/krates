pipeline {
  agent {
    node {
      label 'local'
    }

  }
  stages {
    stage('Checkout') {
      steps {
        git(url: 'https://staticpagesio@bitbucket.org/staticpagesio/krates.git', branch: 'krates/cli/blue-ocean', changelog: true, credentialsId: 'staticpagesio')
      }
    }
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