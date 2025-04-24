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
        // Nexus credentials from Jenkins credentials store
        NEXUS_CREDENTIALS_ID = 'nexus-credentials'
        // Update these URLs as needed. Here, use the releases URL for release builds,
        // but for snapshot builds (like yours), we only deploy to the snapshots URL.
        DEPLOY_REPO_URL      = 'http://localhost:8081/repository/maven-releases/'
        DEPLOY_SNAPSHOT_URL  = 'http://localhost:8081/repository/maven-snapshots/'
    }

    stages {
        // ... (other stages remain unchanged)
        stage('Archivage') {
            parallel {
                stage('Nexus') {
                    steps {
                        dir('Ecommerce_Store') {
                            // Provide the managed settings.xml from Jenkins using its ID.
                            configFileProvider([configFile(fileId: 'f48d6e64-fa5d-4d00-8e66-42dee63996d6', targetLocation: 'custom-settings.xml')]) {
                                // Inject Nexus credentials from Jenkins credentials store.
                                withCredentials([
                                    usernamePassword(
                                        credentialsId: "${env.NEXUS_CREDENTIALS_ID}",
                                        usernameVariable: 'NEXUS_USERNAME',
                                        passwordVariable: 'NEXUS_PASSWORD'
                                    )
                                ]) {
                                    // Since the project version is a snapshot, deploy only to the snapshot repository.
                                    sh """
                                        mvn --batch-mode clean deploy \\
                                          --settings custom-settings.xml \\
                                          -DaltSnapshotRepository=nexus::default::${DEPLOY_SNAPSHOT_URL} \\
                                          -DnexusUser=${NEXUS_USERNAME} \\
                                          -DnexusPass=${NEXUS_PASSWORD}
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }
        // ... (remaining stages)
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
