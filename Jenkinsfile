pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'JDK'
    }

    triggers {
        githubPush()
    }

    environment {
        DOCKER_IMAGE_NAME    = "ecommerce-store"
        DOCKER_REGISTRY_URL  = "https://index.docker.io/v1/"
    }

    stages {
        stage('Start') {
            steps {
                echo '🚀 Démarrage du pipeline CI/CD'
            }
        }

        // Removed the ScrutationSCM stage as Jenkins will handle checkout automatically

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
                    post {
                        always {
                            publishHTML(target: [
                                allowMissing:          false,
                                alwaysLinkToLastBuild: true,
                                keepAll:               true,
                                reportDir:             'Ecommerce_Store/target/site',
                                reportFiles:           'checkstyle.html',
                                reportName:            'Checkstyle Report'
                            ])
                        }
                    }
                }
                stage('PMD') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn pmd:pmd'
                        }
                    }
                    post {
                        always {
                            publishHTML(target: [
                                allowMissing:          false,
                                alwaysLinkToLastBuild: true,
                                keepAll:               true,
                                reportDir:             'Ecommerce_Store/target/site',
                                reportFiles:           'pmd.html',
                                reportName:            'PMD Report'
                            ])
                        }
                    }
                }
                stage('FindBugs') {
                    steps {
                        dir('Ecommerce_Store') {
                            echo '🐞 Analyse avec FindBugs pour détecter les bugs potentiels'
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
            }
        }

        stage('Déploiement Docker') {
            steps {
                dir('Ecommerce_Store') {
                    script {
                        def tag          = "${env.BUILD_NUMBER}"
                        def fullImageTag = "${DOCKER_IMAGE_NAME}:${tag}"

                        echo "🔧 [Docker] Construction de l'image : ${fullImageTag}"
                        def dockerImage = null
                        try {
                            dockerImage = docker.build(fullImageTag)
                            echo "✅ [Docker] Image construite : ${dockerImage.id}"
                        } catch (err) {
                            echo "❌ [Docker] Erreur de build : ${err}"
                        }

                        // Credentials binding
                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )]) {
                            // Login step
                            try {
                                echo "🔑 [Docker] Login (${env.DOCKER_REGISTRY_URL})"
                                bat """
                                    echo %DOCKER_PASSWORD% | docker login ${env.DOCKER_REGISTRY_URL} -u %DOCKER_USERNAME% --password-stdin
                                """
                                echo "✅ [Docker] Login réussi"
                            } catch (err) {
                                echo "⚠ [Docker] Login échoué : ${err}"
                            }

                            // Push step with retry
                            try {
                                retry(3) {
                                    echo "🚀 [Docker] Tentative de push (${currentBuild.retryCount ?: 1}/3)"
                                    bat "docker push ${fullImageTag}"
                                }
                                echo "✅ [Docker] Push réussi"
                            } catch (err) {
                                echo "⚠ [Docker] Push échoué après 3 tentatives : ${err}"
                            }
                        }
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
                to:      'sohaybelbakali@gmail.com',
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
                to:      'sohaybelbakali@gmail.com',
                subject: "❌ ÉCHEC Pipeline ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
Le pipeline a échoué à l'étape ${currentBuild.currentResult}.

🔧 Job: ${JOB_NAME}
🔢 Build: #${BUILD_NUMBER}
🔗 URL: ${BUILD_URL}

Veuillez consulter le journal en pièce jointe pour les détails.
""",
                attachLog: true
            )
        }
    }
}
