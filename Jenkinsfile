pipeline {
  agent any
  stages {
    stage('generate') {
      steps {
        sh '''hexo clean
hexo generate
cp -rf bearcat-examples public/examples'''
      }
    }
  }
}