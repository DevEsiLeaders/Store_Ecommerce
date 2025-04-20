pipeline {
    agent any
    
    tools {
        maven 'maven' // Assure-toi que 'maven' est configuré dans Jenkins
        jdk 'JDK' // Assure-toi que JDK est correctement configuré
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                // Naviguer dans le dossier 'ecommerce_store' avant d'exécuter Maven
                dir('Ecommerce_Store') {
                    bat 'mvn install'
                }
            }
            post {
                success {
                    junit 'target/surefire-reports/**/*.xml'
                }
            }
        }
    }
}

