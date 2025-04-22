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
                        
                        // Build the Docker image with detailed error handling
                        try {
                            echo "📦 Début du build Docker"
                            bat "docker build -t ${DOCKER_IMAGE_NAME}:${tag} ."
                            echo "✅ Image Docker construite avec succès: ${DOCKER_IMAGE_NAME}:${tag}"
                            
                            // Debug: Inspect the built image to verify size and configuration
                            bat "docker images ${DOCKER_IMAGE_NAME}:${tag} --format \"{{.Repository}}:{{.Tag}} - {{.Size}}\""
                        } catch (Exception e) {
                            echo "❌ ERREUR de construction Docker: ${e.message}"
                            echo "Détails de l'erreur: ${e.toString()}"
                            unstable(message: "Construction Docker échouée")
                            error("Échec de la construction Docker - impossible de continuer le déploiement")
                        }
                        
                        // Push with retries and detailed debugging
                        retry(3) {
                            try {
                                echo "⬆️ Tentative de push de l'image Docker vers Docker Hub (essai ${currentBuild.retryCount + 1}/3)"
                                timeout(time: 5, unit: 'MINUTES') {  // Augmenté à 5 minutes pour permettre des uploads plus volumineux
                                    withCredentials([usernamePassword(
                                        credentialsId: 'dockerhub-creds',
                                        usernameVariable: 'DOCKER_USERNAME',
                                        passwordVariable: 'DOCKER_PASSWORD'
                                    )]) {
                                        // Logout first to avoid credential issues
                                        bat 'docker logout'
                                        echo "🔄 Déconnexion de Docker Hub effectuée"
                                        
                                        // Test network connectivity to Docker Hub
                                        echo "🌐 Vérification de la connectivité avec Docker Hub"
                                        bat "ping -n 3 registry-1.docker.io || echo Ping failed but continuing"
                                        
                                        // Login with verbose error capturing
                                        echo "🔑 Tentative de connexion à Docker Hub avec l'utilisateur %DOCKER_USERNAME%"
                                        def loginOutput = bat(script: 'docker login -u "%DOCKER_USERNAME%" -p "%DOCKER_PASSWORD%" 2>&1', returnStdout: true).trim()
                                        echo "Login output: ${loginOutput}"
                                        
                                        if (!loginOutput.contains("Login Succeeded")) {
                                            error "Échec de la connexion à Docker Hub. Veuillez vérifier les identifiants."
                                        }
                                        
                                        echo "✅ Connexion réussie à Docker Hub"
                                        
                                        // Tag the image for the repository
                                        echo "🏷️ Tag de l'image: ${DOCKER_IMAGE_NAME}:${tag} → %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag}"
                                        bat "docker tag ${DOCKER_IMAGE_NAME}:${tag} %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag}"
                                        
                                        // Push with verbose output and error capture
                                        echo "⬆️ Début du push de l'image vers Docker Hub: %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag}"
                                        bat """
                                            docker push %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag} || (
                                                echo "*** DÉTAILS DE L'ERREUR DE PUSH ***"
                                                echo "Username: %DOCKER_USERNAME%"
                                                echo "Image: ${DOCKER_IMAGE_NAME}:${tag}"
                                                echo "Taille de l'image:"
                                                docker images %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag} --format "{{.Size}}"
                                                docker system info
                                                echo "Vérification des quotas et limites Docker Hub:"
                                                curl -s -u "%DOCKER_USERNAME%:%DOCKER_PASSWORD%" https://hub.docker.com/v2/users/account || echo "Échec de la requête API Docker Hub"
                                                exit 1
                                            )
                                        """
                                        echo "✅ Push Docker réussi vers %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag}"
                                    }
                                }
                            } catch (Exception e) {
                                echo "❌ ÉCHEC de la poussée Docker (essai ${currentBuild.retryCount + 1}/3)"
                                echo "Message d'erreur: ${e.message}"
                                echo "Stack trace: ${e.toString()}"
                                echo "Analyse du problème:"
                                echo "1. Problème d'authentification? → Vérifiez que les identifiants 'dockerhub-creds' sont corrects dans Jenkins"
                                echo "2. Problème de réseau? → Vérifiez la connectivité du serveur Jenkins vers Docker Hub"
                                echo "3. Problème de quota sur Docker Hub? → Vérifiez les limites de votre compte Docker Hub"
                                echo "4. Image trop grande? → Optimisez votre Dockerfile pour réduire la taille de l'image"
                                echo "5. Timeout? → Augmentez la valeur du timeout dans le pipeline"
                                
                                // Check for common error signatures
                                if (e.message.contains("denied") || e.message.contains("authentication")) {
                                    echo "⚠️ Problème d'authentification détecté - vérifiez les identifiants Docker Hub"
                                } else if (e.message.contains("timeout")) {
                                    echo "⚠️ Timeout détecté - le réseau est peut-être lent ou l'image trop volumineuse"
                                } else if (e.message.contains("quota") || e.message.contains("limit")) {
                                    echo "⚠️ Problème de quota détecté - vérifiez les limites de votre compte Docker Hub"
                                }
                                
                                sleep(time: 20, unit: 'SECONDS')  // Wait longer between retries
                                error("Nouvelle tentative de poussée après échec: ${e.message}")
                            }
                        }
                        
                        // Archive the Docker image even if push fails
                        try {
                            echo "📦 Archivage de l'image Docker comme artefact Jenkins"
                            bat """
                                mkdir -p target\\docker-image
                                docker save ${DOCKER_IMAGE_NAME}:${tag} -o target\\docker-image\\${DOCKER_IMAGE_NAME}.tar
                            """
                            archiveArtifacts artifacts: "target/docker-image/${DOCKER_IMAGE_NAME}.tar", fingerprint: true
                            echo "✅ Image Docker archivée avec succès comme artefact Jenkins"
                        } catch (Exception e) {
                            echo "⚠️ Échec de l'archivage de l'image Docker: ${e.message}"
                            echo "Détails: ${e.toString()}"
                            echo "Vérifiez l'espace disque disponible et les permissions"
                        }
                    }
                }
            }
            post {
                success {
                    echo "🎉 Image Docker construite et poussée avec succès!"
                }
                failure {
                    echo "❌ Échec du déploiement Docker, mais le pipeline continue"
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
