pipeline {
    agent any
    
    tools {
        maven 'maven'  // Nom exact de Maven configuré dans Jenkins
        jdk 'JDK'      // Nom exact de JDK configuré dans Jenkins
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
