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
                        echo '⚙️ Exécution des tests de performance (placeholder)'
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
                stage('Artifactory') {
                    steps {
                        echo '📦 Publication vers Artifactory (placeholder si utilisé)'
                    }
                }
            }
        }

        stage('Docker Preconditions') {
            steps {
                dir('Ecommerce_Store') {
                    echo "Vérification des préconditions Docker"
                    script {
                        // Vérifier si le démon Docker est en cours d'exécution
                        try {
                            bat 'docker info'
                            echo "✅ Docker daemon est en cours d'exécution"
                        } catch (Exception e) {
                            error "Le démon Docker n'est pas en cours d'exécution. Veuillez démarrer Docker et réessayer."
                        }
                        
                        // Vérifier si Dockerfile existe
                        if (!fileExists('Dockerfile')) {
                            error "Dockerfile introuvable dans l'espace de travail. Veuillez créer un Dockerfile valide."
                        } else {
                            echo "✅ Dockerfile existe"
                        }
                        
                        // Valider la syntaxe Dockerfile
                        try {
                            bat 'docker run --rm -i hadolint/hadolint < Dockerfile || true'
                            echo "✅ Validation Dockerfile terminée"
                        } catch (Exception e) {
                            echo "⚠ Échec de la validation Dockerfile mais continuation: ${e.message}"
                        }
                        
                        // Nettoyer les anciennes images pour libérer de l'espace
                        try {
                            bat '''
                                FOR /F "tokens=*" %%i IN ('docker images "%DOCKER_IMAGE_NAME%" -q') DO (
                                    docker rmi %%i
                                )
                            '''
                            echo "✅ Nettoyage des anciennes images Docker"
                        } catch (Exception e) {
                            echo "⚠ Échec du nettoyage des images mais continuation: ${e.message}"
                        }
                        
                        // Vérifier l'espace disque disponible
                        bat 'wmic logicaldisk get deviceid,freespace,size'
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
                        
                        // Build the Docker image
                        bat "docker build -t ${DOCKER_IMAGE_NAME}:${tag} ."
                        
                        // Push with retries
                        retry(3) {
                            try {
                                timeout(time: 2, unit: 'MINUTES') {
                                    withCredentials([usernamePassword(
                                        credentialsId: 'dockerhub-credentials',
                                        usernameVariable: 'DOCKER_USERNAME',
                                        passwordVariable: 'DOCKER_PASSWORD'
                                    )]) {
                                        // Logout first to avoid credential issues
                                        bat 'docker logout'
                                        
                                        // Login and push
                                        bat """
                                            docker login -u "%DOCKER_USERNAME%" -p "%DOCKER_PASSWORD%"
                                            docker tag ${DOCKER_IMAGE_NAME}:${tag} %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag}
                                            docker push %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag}
                                        """
                                    }
                                }
                            } catch (Exception e) {
                                echo "Échec de la poussée Docker: ${e.message}"
                                sleep(time: 10, unit: 'SECONDS')
                                error("Nouvelle tentative de poussée")
                            }
                        }
                        
                        // Archive the Docker image even if push fails
                        try {
                            bat """
                                mkdir -p target/docker-image
                                docker save ${DOCKER_IMAGE_NAME}:${tag} -o target/docker-image/${DOCKER_IMAGE_NAME}.tar
                            """
                            archiveArtifacts artifacts: "target/docker-image/${DOCKER_IMAGE_NAME}.tar", fingerprint: true
                            echo "Image Docker archivée comme artefact Jenkins"
                        } catch (Exception e) {
                            echo "Échec de l'archivage de l'image Docker: ${e.message}"
                        }
                    }
                }
            }
            post {
                success {
                    echo "Image Docker construite et poussée avec succès"
                }
                failure {
                    echo "Échec du déploiement Docker, mais le pipeline continue"
                    unstable(message: "Échec du déploiement Docker mais le pipeline continue")
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
