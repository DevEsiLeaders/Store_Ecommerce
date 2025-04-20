pipeline {
    agent any
    
    tools {
        maven 'maven' // Assure-toi que 'maven' est configuré dans Jenkins
        jdk 'JDK' // Assure-toi que JDK est correctement configuré

    }
    
    stages {
        stage('Start') {
            steps {
                echo 'Début du pipeline CI/CD'
            }
        }
        
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }
        
        stage('Build With Maven') {
            steps {
                dir('Ecommerce_store') {
                    bat 'mvn clean install'
                }
            }
            post {
                success {
                    junit 'Ecommerce_store/target/surefire-reports/**/*.xml'
                }
            }
        }
        
        stage('Code Analysis') {
            steps {
                dir('Ecommerce_store') {
                    bat 'mvn pmd:pmd'
                    // bat 'mvn checkstyle:checkstyle'  // Uncomment if using Checkstyle
                }
            }
        }
        
        stage('Unit Testing') {
            steps {
                dir('Ecommerce_store') {
                    echo 'JUnit tests already executed during build'
                }
            }
        }
        
        stage('Performance Testing') {
            steps {
                dir('Ecommerce_store') {
                    echo 'Running performance tests'
                    // Add your performance testing commands here
                }
            }
        }
        
        stage('Generate Documentation') {
            steps {
                dir('Ecommerce_store') {
                    bat 'mvn javadoc:javadoc'
                }
            }
        }
        
        stage('Package Artifacts') {
            steps {
                dir('Ecommerce_store') {
                    echo 'Packaging application'
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }
        
        stage('Publish to Nexus') {
            steps {
                dir('Ecommerce_store') {
                    echo 'Publishing to Nexus repository'
                    // bat 'mvn deploy'  // Uncomment when Nexus is configured
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                dir('Ecommerce_store') {
                    echo 'Building Docker image'
                    // Add your Docker build commands here
                }
            }
        }
        
        stage('Deploy') {
            steps {
                dir('Ecommerce_store') {
                    echo 'Deploying application'
                    // Add your deployment commands here
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
            cleanWs()  // Clean workspace after build
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
            // mail to: 'team@example.com', subject: 'Pipeline Failed', body: 'Please check the build'
        }
    }
}
