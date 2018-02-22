pipeline {
  agent any
  stages {
    stage('generate') {
      steps {
        sh '''yarn install
'''
        sh '''/usr/local/bin/hexo clean
/usr/local/bin/hexo generate
cp -rf bearcat-examples public/examples'''
      }
    }
    stage('deploy') {
      steps {
        sh 'make d'
      }
    }
  }
}