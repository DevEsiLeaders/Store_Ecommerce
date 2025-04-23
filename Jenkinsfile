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

        stage('ScrutationSCM') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[ name: '*/develop' ]],
                    extensions: [],
                    userRemoteConfigs: [[
                        url:           'https://github.com/Badrbernane/Store_Ecommerce.git',
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
                            echo '🔎 Analyse SpotBugs'
                            bat 'mvn spotbugs:spotbugs'
                        }
                    }
                    post {
                        always {
                            publishHTML(target: [
                                allowMissing:          false,
                                alwaysLinkToLastBuild: true,
                                keepAll:               true,
                                reportDir:             'Ecommerce_Store/target/site',
                                reportFiles:           'spotbugs.html',
                                reportName:            'SpotBugs Report'
                            ])
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

      stage('Déploiement Docker Debug') {
    steps {
        dir('Ecommerce_Store') {
            script {
                // Basic diagnostics
                echo "📊 [Debug] Docker diagnostic information:"
                bat 'docker version'
                bat 'docker info'
                
                def tag = "${env.BUILD_NUMBER}"
                def fullImageTag = "${DOCKER_IMAGE_NAME}:${tag}"
                echo "📋 [Debug] Building image: ${fullImageTag}"
                
                // Check for Dockerfile
                bat 'dir'
                echo "📂 [Debug] Checking for Dockerfile existence:"
                bat 'if exist Dockerfile (echo "✅ Dockerfile exists") else (echo "❌ Dockerfile not found")'
                
                // Try building the image with detailed output
                def dockerImage = null
                try {
                    echo "🔧 [Docker] Construction de l'image : ${fullImageTag}"
                    dockerImage = docker.build(fullImageTag)
                    echo "✅ [Docker] Image construite : ${dockerImage.id}"
                    
                    // Verify the image was built
                    bat "docker images | findstr ${DOCKER_IMAGE_NAME}"
                } catch (err) {
                    echo "❌ [Docker] Erreur de build : ${err}"
                    error "Docker build failed: ${err}" // Stop pipeline if build fails
                }
                
                // Credentials binding
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    // Debug username (don't print password!)
                    echo "👤 [Debug] Using Docker Hub username: ${DOCKER_USERNAME}"
                    
                    // Check if we need to use the username in the tag
                    echo "🏷️ [Debug] Checking if we need full namespace in tag"
                    def namespaceImageTag = "${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${tag}"
                    echo "🔄 [Debug] Alternative full tag would be: ${namespaceImageTag}"
                    
                    // Login step
                    try {
                        echo "🔑 [Docker] Login to ${env.DOCKER_REGISTRY_URL}"
                        bat """
                            echo %DOCKER_PASSWORD% | docker login ${env.DOCKER_REGISTRY_URL} -u %DOCKER_USERNAME% --password-stdin
                        """
                        echo "✅ [Docker] Login réussi"
                        
                        // Check login status
                        bat 'docker system info | findstr "Username"'
                    } catch (err) {
                        echo "⚠ [Docker] Login échoué : ${err}"
                        error "Docker login failed: ${err}" // Stop pipeline if login fails
                    }
                    
                    // Try with namespace tag first
                    echo "🔄 [Debug] Tagging with namespace"
                    bat "docker tag ${fullImageTag} ${namespaceImageTag}"
                    bat "docker images | findstr ${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}"
                    
                    // Push with namespace
                    try {
                        echo "🚀 [Docker] Tentative de push avec namespace: ${namespaceImageTag}"
                        bat "docker push ${namespaceImageTag}"
                        echo "✅ [Docker] Push avec namespace réussi"
                    } catch (err) {
                        echo "⚠ [Docker] Push avec namespace échoué : ${err}"
                        
                        // Try original tag as fallback
                        try {
                            echo "🔄 [Debug] Fallback - attempting push with original tag: ${fullImageTag}"
                            bat "docker push ${fullImageTag}"
                            echo "✅ [Docker] Push avec tag original réussi"
                        } catch (err2) {
                            echo "❌ [Docker] Push avec tag original échoué : ${err2}"
                            error "All Docker push attempts failed"
                        }
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
