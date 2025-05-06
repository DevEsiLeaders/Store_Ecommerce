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
        NEXUS_CREDENTIALS_ID = 'nexus-credentials'
        DEPLOY_REPO_URL      = 'http://localhost:8081/repository/maven-releases/'
        DEPLOY_SNAPSHOT_URL  = 'http://localhost:8081/repository/maven-snapshots/'
        KUBE_CONFIG_CREDENTIALS_ID = 'kubeconfig-credentials' // Kubernetes kubeconfig credentials in Jenkins
    }
    stages {
        // Existing stages here...

        stage('Déploiement Docker') {
            steps {
                dir('Ecommerce_Store') {
                    script {
                        def tag = "${env.BUILD_NUMBER}"
                        def fullImageTag = "${DOCKER_IMAGE_NAME}:${tag}"
                        // Build docker image
                        echo "🔧 [Docker] Construction de l'image : ${fullImageTag}"
                        def dockerImage = docker.build(fullImageTag)
                        echo "✅ [Docker] Image construite"
                        // Credentials binding
                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )]) {
                            // Create properly namespaced tag (required for Docker Hub)
                            def namespaceImageTag = "${DOCKER_USERNAME}/${DOCKER_IMAGE_NAME}:${tag}"
                            bat "docker tag ${fullImageTag} ${namespaceImageTag}"
                            // Direct login approach
                            bat "docker logout"
                            bat "docker login -u %DOCKER_USERNAME% -p %DOCKER_PASSWORD%"
                            // Push with namespace
                            bat "docker push ${namespaceImageTag}"
                            echo "✅ [Docker] Push réussi"
                        }
                    }
                }
            }
        }

        stage('Déploiement Kubernetes') {
            steps {
                withCredentials([file(credentialsId: "${env.KUBE_CONFIG_CREDENTIALS_ID}", variable: 'KUBECONFIG')]) {
                    script {
                        echo "🚀 [Kubernetes] Déploiement sur le cluster Kubernetes"
                        sh """
                            # Use the kubeconfig provided by Jenkins
                            export KUBECONFIG=${KUBECONFIG}

                            # Apply deployment and service YAMLs
                            kubectl apply -f deployment.yaml
                            kubectl apply -f service.yaml

                            # Check the status of the deployment
                            kubectl rollout status deployment/ecommerce-store
                        """
                        echo "✅ [Kubernetes] Déploiement terminé avec succès"
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
        success {
            echo "[DEBUG] Preparing to send success email..."
            emailext(
                to: 'badrbernane6@gmail.com',
                from: 'badrbernane6@gmail.com',
                subject: "gooooood Succes Pipeline ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
Le pipeline s'est termine avec succes.
 Job: ${JOB_NAME}
 Build: #${BUILD_NUMBER}
 URL: ${BUILD_URL}
"""
            )
            echo "[DEBUG] Success email step completed."
        }
        failure {
            echo "[DEBUG] Preparing to send failure email..."
            emailext(
                to: 'badrbernane6@gmail.com',
                from: 'badrbernane6@gmail.com',
                subject: "❌ ÉCHEC Pipeline ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
Le pipeline a échoué à l'étape ${env.BUILD_STATUS}.
🔧 Job: ${JOB_NAME}
🔢 Build: #${BUILD_NUMBER}
🔗 URL: ${BUILD_URL}
Veuillez consulter le journal en pièce jointe pour les détails.
""",
                attachLog: true
            )
            echo "[DEBUG] Failure email step completed."
        }
        always {
            echo "[DEBUG] Cleaning up workspace..."
            cleanWs() // Cleanup after email notifications
            echo "[DEBUG] Workspace cleaned."
        }
    }
}