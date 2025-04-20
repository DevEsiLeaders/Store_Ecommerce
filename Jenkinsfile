pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'JDK'
    }

    stages {
        stage('Start') {
            steps {
                echo 'Démarrage du workflow CI/CD'
            }
        }

        // Checkout avec credentials GitHub
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/develop']],
                    extensions: [],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Badrbernane/Store_Ecommerce.git',
                        credentialsId: 'github-token' 
                    ]]
                ])
            }
        }

        stage('Build') {
            steps {
                dir('Ecommerce_Store') {
                    bat 'mvn clean install'
                }
            }
            post {
                success {
                    dir('Ecommerce_Store') {
                        junit 'target/surefire-reports/*.xml'
                    }
                }
            }
        }

        stage('Test') {
            parallel {
                stage('JUnit') {
                    steps {
                        dir('Ecommerce_Store') {
                            echo 'Rapports JUnit déjà générés'
                        }
                    }
                }
                stage('Performance testing') {
                    steps {
                        dir('Ecommerce_Store') {
                            echo 'Exécution des tests de performance'
                            // Ajouter commandes JMeter/Gatling ici
                        }
                    }
                }
            }
        }

        stage('Analyse du code') {
            parallel {
                stage('PMD') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn pmd:pmd'
                        }
                    }
                }
                stage('Checkstyle') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn checkstyle:checkstyle'
                        }
                    }
                }
            }
        }

        stage('JavaDoc') {
            steps {
                dir('Ecommerce_Store') {
                    bat 'mvn javadoc:javadoc'
                }
            }
        }

        stage('Packaging') {
            steps {
                dir('Ecommerce_Store') {
                    echo 'Génération du package'
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }

        stage('Archivage') {
            steps {
                dir('Ecommerce_Store') {
                    echo 'Archivage des artefacts'
                }
            }
        }

        stage('Déploiement') {
            parallel {
                stage('Nexus') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn deploy'
                        }
                    }
                }
                /*
                stage('Publication de l\'image') {
                    steps {
                        dir('Ecommerce_Store') {
                            script {
                                docker.build("ecommerce-image", ".")
                                docker.withRegistry('https://your-registry', 'docker-creds') {
                                    docker.image("ecommerce-image").push()
                                }
                            }
                        }
                    }
                }
                */
            }
        }

        stage('End') {
            steps {
                echo 'Workflow CI/CD terminé avec succès'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            emailext (
                to: 'sohaybelbakali@gmail.com',
                subject: "Succès Pipeline ${JOB_NAME} #${BUILD_NUMBER}",
                body: """Le pipeline a réussi.

Détails:
Job: ${JOB_NAME}
Build: #${BUILD_NUMBER}
URL: ${BUILD_URL}"""
            )
        }
        failure {
            emailext (
                to: 'sohaybelbakali@gmail.com',
                subject: "ÉCHEC Pipeline ${JOB_NAME} #${BUILD_NUMBER}",
                body: """Le pipeline a échoué à l'étape ${currentBuild.currentResult}.

Détails:
Job: ${JOB_NAME}
Build: #${BUILD_NUMBER}
URL: ${BUILD_URL}

Veuillez corriger les problèmes."""
                , attachLog: true
            )
        }
    }
}

