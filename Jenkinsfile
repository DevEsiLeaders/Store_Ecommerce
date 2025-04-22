pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'JDK'
    }

    environment {
        DOCKER_IMAGE_NAME = "ecommerce-store"
    }

    stages {
        stage('Start') {
            steps {
                echo '🚀 Démarrage du pipeline CI/CD'
            }
        }

        stage('ScrutationSCM') {
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
            parallel {
                stage('Build With Maven') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn clean install -DskipTests'
                        }
                    }
                }
            }
        }

        stage('Test') {
            parallel {
                stage('JUnit') {
                    steps {
                        dir('Ecommerce_Store') {
                            echo '📋 Génération des rapports JUnit'
                            bat 'mvn test'
                            junit 'target/surefire-reports/*.xml'
                        }
                    }
                }
                stage('Functional testing') {
                    steps {
                        echo '🔍 Tests fonctionnels manquants — à définir si besoin'
                    }
                }
                stage('Performance testing') {
                    steps {
                        echo '⚙ Exécution des tests de performance (placeholder)'
                    }
                }
            }
        }

        stage('Analyse du code') {
            parallel {
                stage('Checkstyle') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn checkstyle:checkstyle'
                        }
                    }
                }
               
                stage('PMD') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn pmd:pmd'
                        }
                    }
                }
                
                stage('FindBugs') {
                    steps {
                        dir('Ecommerce_Store') {
                            echo '🐞 Analyse avec FindBugs pour détecter les bugs potentiels'
                            bat 'mvn spotbugs:spotbugs'
                            // Alternatively, if using the older FindBugs plugin:
                            // bat 'mvn findbugs:findbugs'
                            
                            // Optionally publish the report
                            recordIssues(tools: [spotBugs(pattern: 'target/spotbugsXml.xml')])
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
                    // Use double quotes to allow the apostrophe in "l'application"
                    echo "📦 Packaging de l'application"
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }

        stage('Archivage') {
            parallel {
                stage('Nexus') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn deploy'
                        }
                    }
                }
                stage('Artifactory') {
                    steps {
                        echo '📦 Publication vers Artifactory (placeholder si utilisé)'
                    }
                }
            }
        }

        stage('Déploiement Docker') {
            steps {
                dir('Ecommerce_Store') {
                    script {
                        def tag = "${env.BUILD_NUMBER}"
                        echo "🔧 Construction de l'image Docker : ${DOCKER_IMAGE_NAME}:${tag}"
                        
                        // More detailed output
                        echo "🐳 Docker build en cours..."
                        echo "📦 Utilisation du Dockerfile présent dans: ${WORKSPACE}/Ecommerce_Store"
                        
                        // Build the image with more verbose output
                        def dockerImage = docker.build("${DOCKER_IMAGE_NAME}:${tag}")
                        
                        // Additional visual feedback
                        echo "✅ Image Docker construite avec succès: ${dockerImage.id}"
                        
                        // Optionally display docker images (for debugging)
                        sh(script: "docker images | grep ${DOCKER_IMAGE_NAME}", returnStdout: true).trim()
                    }
                }
            }
        }

        stage('End') {
            steps {
                echo '✅ Pipeline CI/CD terminé avec succès !'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            emailext(
                to: 'sohaybelbakali@gmail.com',
                subject: "✅ Succès Pipeline ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
Le pipeline s'est terminé avec succès.

🔧 Job: ${JOB_NAME}
🔢 Build: #${BUILD_NUMBER}
🔗 URL: ${BUILD_URL}
"""
            )
        }
        failure {
            emailext(
                to: 'sohaybelbakali@gmail.com',
                subject: "❌ ÉCHEC Pipeline ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
Le pipeline a échoué à l'étape ${currentBuild.currentResult}. 

🔧 Job: ${JOB_NAME}
🔢 Build: #${BUILD_NUMBER}
🔗 URL: ${BUILD_URL}

Veuillez consulter le journal en pièce jointe pour les détails.
""", attachLog: true
            )
        }
    }
}
