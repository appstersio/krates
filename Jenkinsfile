pipeline {
  // Pipeline syntax here: https://jenkins.io/doc/book/pipeline/syntax/
  // agent
  agent any

  // options
  options {
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')
  }
  // stages
  stages {
    stage('make build') {
      steps { sh 'make build' }
    }
    stage('make release-up') {
      steps { sh 'make release-up' }
    }
    stage('make test') {
      steps { sh 'make test' }
    }
    stage('make gemspec') {
      steps { sh 'make gemspec' }
    }
    stage('make credspec') {
      steps { sh 'make credspec' }
    }
    stage('make publish') {
      when {
        branch 'master'
        expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
      }
      steps { sh 'make publish' }
    }
    stage('make teardown') {
      steps { sh 'make teardown' }
    }
  }
}