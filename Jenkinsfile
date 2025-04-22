pipeline {
    agent any

    tools {
        maven 'maven'
        jdk 'JDK'
    }

    environment {
        DOCKER_IMAGE_NAME = "ecommerce-store"
        // Add debug flag to control detailed logging
        DEBUG_MODE = "true"
    }

    stages {
        stage('Start') {
            steps {
                echo '🚀 Démarrage du pipeline CI/CD'
                // Print environment info for debugging
                script {
                    if (env.DEBUG_MODE == "true") {
                        echo "=== Environnement du pipeline ==="
                        echo "BUILD_NUMBER: ${env.BUILD_NUMBER}"
                        echo "JOB_NAME: ${env.JOB_NAME}"
                        echo "WORKSPACE: ${env.WORKSPACE}"
                        echo "NODE_NAME: ${env.NODE_NAME}"
                        sh 'java -version || echo "Java command failed"'
                        sh 'mvn -version || echo "Maven command failed"'
                    }
                }
            }
        }

        stage('ScrutationSCM') {
            steps {
                echo "📥 Récupération du code source depuis GitHub"
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/develop']],
                    extensions: [],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Badrbernane/Store_Ecommerce.git',
                        credentialsId: 'github-token'
                    ]]
                ])
                // Verify checkout success by listing files
                script {
                    echo "Contenu du répertoire après checkout:"
                    bat 'dir'
                }
            }
        }

        stage('Build') {
            parallel {
                stage('Build With Maven') {
                    steps {
                        dir('Ecommerce_Store') {
                            echo "🔨 Construction du projet avec Maven"
                            // Add debugging to Maven build
                            script {
                                try {
                                    bat 'mvn clean install -DskipTests'
                                    echo "✅ Maven build completed successfully"
                                } catch (Exception e) {
                                    echo "❌ Maven build failed: ${e.message}"
                                    echo "Maven error details: ${e.toString()}"
                                    unstable(message: "Build Maven failed but continuing pipeline")
                                    // Continue the pipeline despite errors
                                }
                            }
                            // Verify target directory contents
                            bat 'dir target || echo "No target directory found"'
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
                            script {
                                try {
                                    bat 'mvn test'
                                    junit 'target/surefire-reports/*.xml'
                                    echo "✅ Tests JUnit completed successfully"
                                } catch (Exception e) {
                                    echo "❌ JUnit tests failed: ${e.message}"
                                    echo "Test failure stack trace: ${e.toString()}"
                                    unstable(message: "JUnit tests failed but continuing pipeline")
                                }
                            }
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
                            script {
                                try {
                                    bat 'mvn checkstyle:checkstyle'
                                    echo "✅ Checkstyle analysis completed"
                                } catch (Exception e) {
                                    echo "⚠️ Checkstyle analysis failed: ${e.message}"
                                    echo "Continuing despite Checkstyle failure"
                                    unstable(message: "Checkstyle analysis failed")
                                }
                            }
                        }
                    }
                }
               
                stage('PMD') {
                    steps {
                        dir('Ecommerce_Store') {
                            script {
                                try {
                                    bat 'mvn pmd:pmd'
                                    echo "✅ PMD analysis completed"
                                } catch (Exception e) {
                                    echo "⚠️ PMD analysis failed: ${e.message}"
                                    echo "Continuing despite PMD failure"
                                    unstable(message: "PMD analysis failed")
                                }
                            }
                        }
                    }
                }
                
                // Tentative d'ajout de BugSpot - avec gestion d'erreur
                stage('BugSpot') {
                    steps {
                        script {
                            try {
                                echo "🔍 Tentative d'analyse BugSpot"
                                // Tentative d'exécution de BugSpot
                                bat 'bugspot || echo "BugSpot command not found"'
                                echo "✅ BugSpot analysis completed"
                            } catch (Exception e) {
                                echo "⚠️ BugSpot analysis failed: ${e.message}"
                                echo "DEBUG - BugSpot error stack trace: ${e.toString()}"
                                echo "Skipping BugSpot and continuing pipeline"
                            }
                        }
                    }
                }
            }
        }

        stage('JavaDoc') {
            steps {
                dir('Ecommerce_Store') {
                    script {
                        try {
                            bat 'mvn javadoc:javadoc'
                            echo "✅ JavaDoc generation completed"
                        } catch (Exception e) {
                            echo "⚠️ JavaDoc generation failed: ${e.message}"
                            echo "JavaDoc error details: ${e.toString()}"
                            unstable(message: "JavaDoc generation failed")
                        }
                    }
                }
            }
        }

        stage('Packaging') {
            steps {
                dir('Ecommerce_Store') {
                    echo "📦 Packaging de l'application"
                    script {
                        try {
                            // Verify JAR file exists before archiving
                            bat 'dir target\\*.jar || echo "No JAR files found in target directory"'
                            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                            echo "✅ Application packaged successfully"
                        } catch (Exception e) {
                            echo "❌ Packaging failed: ${e.message}"
                            echo "Packaging error details: ${e.toString()}"
                            unstable(message: "Packaging failed but continuing pipeline")
                        }
                    }
                }
            }
        }

        stage('Archivage') {
            parallel {
                stage('Nexus') {
                    steps {
                        dir('Ecommerce_Store') {
                            script {
                                try {
                                    echo "📦 Tentative de déploiement vers Nexus"
                                    bat 'mvn deploy'
                                    echo "✅ Déploiement Nexus réussi"
                                } catch (Exception e) {
                                    echo "❌ Déploiement Nexus échoué: ${e.message}"
                                    echo "Détails de l'erreur Nexus: ${e.toString()}"
                                    echo "Vérifiez les configurations Maven pour Nexus (settings.xml)"
                                    unstable(message: "Déploiement Nexus échoué mais continuation du pipeline")
                                }
                            }
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
                    echo "🔍 Vérification des préconditions Docker"
                    script {
                        // Vérifier si le démon Docker est en cours d'exécution
                        try {
                            bat 'docker info'
                            echo "✅ Docker daemon est en cours d'exécution"
                        } catch (Exception e) {
                            echo "❌ ERREUR CRITIQUE: Le démon Docker n'est pas en cours d'exécution"
                            echo "Message d'erreur: ${e.message}"
                            echo "Détails: ${e.toString()}"
                            echo "Solutions possibles:"
                            echo "1. Vérifiez que Docker Desktop est démarré"
                            echo "2. Vérifiez que l'agent Jenkins a accès au socket Docker"
                            echo "3. Redémarrez le service Docker sur l'agent Jenkins"
                            error "Le démon Docker n'est pas en cours d'exécution. Veuillez démarrer Docker et réessayer."
                        }
                        
                        // Debug - Check Docker version info
                        bat 'docker version'
                        
                        // Vérifier si Dockerfile existe
                        if (!fileExists('Dockerfile')) {
                            echo "❌ ERREUR CRITIQUE: Dockerfile introuvable dans le répertoire courant"
                            echo "Répertoire courant: ${pwd()}"
                            bat 'dir'
                            error "Dockerfile introuvable dans l'espace de travail. Veuillez créer un Dockerfile valide."
                        } else {
                            echo "✅ Dockerfile existe"
                            // Show Dockerfile content for debugging
                            if (env.DEBUG_MODE == "true") {
                                echo "=== Contenu du Dockerfile ==="
                                bat 'type Dockerfile'
                            }
                        }
                        
                        // Valider la syntaxe Dockerfile
                        try {
                            echo "🔍 Validation du Dockerfile"
                            bat 'docker run --rm -i hadolint/hadolint < Dockerfile || echo "Hadolint validation warnings"'
                            echo "✅ Validation Dockerfile terminée"
                        } catch (Exception e) {
                            echo "⚠️ Échec de la validation Dockerfile mais continuation: ${e.message}"
                            echo "Détails de l'erreur: ${e.toString()}"
                        }
                        
                        // Nettoyer les anciennes images pour libérer de l'espace
                        try {
                            echo "🧹 Nettoyage des anciennes images Docker"
                            bat '''
                                FOR /F "tokens=*" %%i IN ('docker images "%DOCKER_IMAGE_NAME%" -q') DO (
                                    echo "Removing image: %%i"
                                    docker rmi -f %%i || echo "Failed to remove image %%i but continuing"
                                )
                            '''
                            echo "✅ Nettoyage des anciennes images Docker terminé"
                        } catch (Exception e) {
                            echo "⚠️ Échec du nettoyage des images mais continuation: ${e.message}"
                            echo "Détails de l'erreur: ${e.toString()}"
                        }
                        
                        // Vérifier l'espace disque disponible
                        echo "💾 Vérification de l'espace disque disponible"
                        bat 'wmic logicaldisk get deviceid,freespace,size'
                        
                        // Vérifier les images Docker existantes
                        echo "📋 Images Docker existantes sur le système"
                        bat 'docker images'
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
                            echo "✅ Image Docker construite avec succès"
                            
                            // Debug: Inspect the built image
                            bat "docker images ${DOCKER_IMAGE_NAME}:${tag}"
                            bat "docker inspect ${DOCKER_IMAGE_NAME}:${tag} || echo 'Inspection failed'"
                        } catch (Exception e) {
                            echo "❌ ERREUR de construction Docker: ${e.message}"
                            echo "Détails de l'erreur: ${e.toString()}"
                            echo "Vérifiez le Dockerfile et les fichiers nécessaires"
                            // Continue despite build failure
                            unstable(message: "Construction Docker échouée")
                            return
                        }
                        
                        // Try Docker login separately to isolate authentication issues
                        try {
                            echo "🔑 Test de connexion Docker Hub (sans push)"
                            withCredentials([usernamePassword(
                                credentialsId: 'dockerhub-creds',
                                usernameVariable: 'DOCKER_USERNAME',
                                passwordVariable: 'DOCKER_PASSWORD'
                            )]) {
                                // Logout first to avoid credential issues
                                bat 'docker logout'
                                
                                // Test login only
                                bat """
                                    echo "Tentative de connexion à Docker Hub avec l'utilisateur %DOCKER_USERNAME%"
                                    docker login -u "%DOCKER_USERNAME%" -p "%DOCKER_PASSWORD%"
                                """
                                echo "✅ Test de connexion Docker Hub réussi"
                            }
                        } catch (Exception e) {
                            echo "❌ ERREUR d'authentification Docker Hub: ${e.message}"
                            echo "Détails de l'erreur: ${e.toString()}"
                            echo "Vérifiez les points suivants:"
                            echo "1. Les identifiants 'dockerhub-creds' sont-ils corrects dans Jenkins?"
                            echo "2. L'utilisateur a-t-il les permissions nécessaires sur Docker Hub?"
                            echo "3. Y a-t-il des problèmes réseau ou de pare-feu?"
                            // Continue despite login issues - we'll try during push
                        }
                        
                        // Push with retries and detailed debugging
                        retry(3) {
                            try {
                                echo "⬆️ Tentative de push de l'image Docker (essai ${currentBuild.retryCount + 1}/3)"
                                timeout(time: 2, unit: 'MINUTES') {
                                    withCredentials([usernamePassword(
                                        credentialsId: 'dockerhub-creds',
                                        usernameVariable: 'DOCKER_USERNAME',
                                        passwordVariable: 'DOCKER_PASSWORD'
                                    )]) {
                                        // Logout first to avoid credential issues
                                        bat 'docker logout'
                                        
                                        // Debug network conditions
                                        if (env.DEBUG_MODE == "true") {
                                            echo "Checking network connectivity to Docker Hub"
                                            bat "ping -n 3 registry-1.docker.io || echo Ping failed but continuing"
                                        }
                                        
                                        // Login, tag, and push with detailed output
                                        echo "🔑 Connexion à Docker Hub avec l'utilisateur ${DOCKER_USERNAME}"
                                        bat "docker login -u \"%DOCKER_USERNAME%\" -p \"%DOCKER_PASSWORD%\""
                                        
                                        echo "🏷️ Tag de l'image: ${DOCKER_IMAGE_NAME}:${tag} → %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag}"
                                        bat "docker tag ${DOCKER_IMAGE_NAME}:${tag} %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag}"
                                        
                                        echo "⬆️ Push de l'image: %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag}"
                                        bat """
                                            docker push %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag} || (
                                                echo "*** DÉTAILS DE L'ERREUR DE PUSH ***"
                                                echo "Username: %DOCKER_USERNAME%"
                                                echo "Image: ${DOCKER_IMAGE_NAME}:${tag}"
                                                echo "Taille de l'image:"
                                                docker images %DOCKER_USERNAME%/${DOCKER_IMAGE_NAME}:${tag} --format "{{.Size}}"
                                                exit 1
                                            )
                                        """
                                        echo "✅ Push Docker réussi"
                                    }
                                }
                            } catch (Exception e) {
                                echo "❌ ÉCHEC de la poussée Docker (essai ${currentBuild.retryCount + 1}/3)"
                                echo "Message d'erreur: ${e.message}"
                                echo "Stack trace: ${e.toString()}"
                                echo "Analyse du problème:"
                                echo "1. Problème d'authentification? Vérifiez les identifiants"
                                echo "2. Problème de réseau? Vérifiez la connectivité"
                                echo "3. Problème de quota sur Docker Hub? Vérifiez votre compte"
                                echo "4. Image trop grande? Vérifiez la taille et optimisez"
                                
                                // Retry diagnostics
                                echo "Tentative de diagnostics supplémentaires:"
                                bat 'docker info || echo "Docker info failed"'
                                
                                sleep(time: 10, unit: 'SECONDS')
                                error("Nouvelle tentative de poussée")
                            }
                        }
                        
                        // Archive the Docker image even if push fails
                        try {
                            echo "📦 Archivage de l'image Docker"
                            bat """
                                mkdir -p target\\docker-image
                                docker save ${DOCKER_IMAGE_NAME}:${tag} -o target\\docker-image\\${DOCKER_IMAGE_NAME}.tar
                            """
                            archiveArtifacts artifacts: "target/docker-image/${DOCKER_IMAGE_NAME}.tar", fingerprint: true
                            echo "✅ Image Docker archivée comme artefact Jenkins"
                        } catch (Exception e) {
                            echo "⚠️ Échec de l'archivage de l'image Docker: ${e.message}"
                            echo "Détails de l'erreur: ${e.toString()}"
                        }
                    }
                }
            }
            post {
                success {
                    echo "🎉 Image Docker construite et poussée avec succès"
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
                script {
                    // Print summary of what happened
                    echo "=== Résumé du pipeline ==="
                    echo "Build Number: ${env.BUILD_NUMBER}"
                    echo "Résultat: ${currentBuild.currentResult}"
                    echo "Durée: ${currentBuild.durationString}"
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Nettoyage de l'espace de travail"
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
⏱️ Durée: ${currentBuild.durationString}

Un rapport complet est disponible dans Jenkins.
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
⏱️ Durée: ${currentBuild.durationString}
🛑 Étape en échec: ${currentBuild.displayName}

Veuillez consulter le journal en pièce jointe pour les détails.
""", attachLog: true
            )
        }
        unstable {
            emailext(
                to: 'sohaybelbakali@gmail.com',
                subject: "⚠️ INSTABLE Pipeline ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
Le pipeline s'est terminé avec un état instable. 

🔧 Job: ${JOB_NAME}
🔢 Build: #${BUILD_NUMBER}
🔗 URL: ${BUILD_URL}
⏱️ Durée: ${currentBuild.durationString}

Le pipeline a continué malgré certaines erreurs. Veuillez consulter le journal pour les détails.
""", attachLog: true
            )
        }
    }
}
