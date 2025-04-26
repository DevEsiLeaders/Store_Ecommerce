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
                    branches: [[ name: '*/main' ]],
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
                    post {
                        always {
                            publishHTML(target: [
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'Ecommerce_Store/target/site',
                                reportFiles: 'checkstyle.html',
                                reportName: 'Checkstyle Report'
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
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'Ecommerce_Store/target/site',
                                reportFiles: 'pmd.html',
                                reportName: 'PMD Report'
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
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'Ecommerce_Store/target/site',
                                reportFiles: 'spotbugs.html',
                                reportName: 'SpotBugs Report'
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
                            // Provide the managed settings.xml from Jenkins (server id: nexus)
                            configFileProvider([configFile(fileId: 'f48d6e64-fa5d-4d00-8e66-42dee63996d6', targetLocation: 'custom-settings.xml')]) {
                                // Inject Nexus credentials
                                withCredentials([
                                    usernamePassword(
                                        credentialsId: "${env.NEXUS_CREDENTIALS_ID}",
                                        usernameVariable: 'NEXUS_USERNAME',
                                        passwordVariable: 'NEXUS_PASSWORD'
                                    )
                                ]) {
                                    // As the project version is SNAPSHOT, deploy to the snapshot repo.
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


        stage('End') {
            steps {
                echo '✅ Pipeline CI/CD terminé avec succès !'
            }
        }
    }

    post {
    success {
        emailext(
            to: 'badrbernane6@gmail.com',
            from: 'your-verified-email@domain.com',
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
            to: 'badrbernane6@gmail.com',
            from: 'your-verified-email@domain.com',
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
    }
    always {
        cleanWs() // Cleanup after email notifications
    }
}
