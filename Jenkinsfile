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
  }
  post {
    always {
      sh 'make teardown'
    }
  }
}