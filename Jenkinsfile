pipeline {
    agent any
    
    tools {
        maven 'Maven 3.5.2'
        jdk 'jdk-21.0.6'
    }
    
    stages {
        stage('Build') {
            steps {
                bat 'mvn install'
            }
            post {
                success {
                    junit 'target/surefire-reports/**/*.xml'
                }
            }
        }
    }
}
