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
                    branches: [[ name: '*/main' ]],
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
                script {
                    echo "🔍 Checking Maven and Java versions"
                    bat "mvn --version"
                    bat "java -version"
                    
                    echo "🔍 Checking Ecommerce_Store directory content"
                    bat "dir Ecommerce_Store /a"
                }
                
                configFileProvider([configFile(fileId: 'global-settings-xml', targetLocation: 'settings.xml')]) {
                    echo "🔍 Verifying settings.xml was created"
                    bat "if exist settings.xml (echo Settings file found) else (echo Settings file NOT found)"
                    
                    dir('Ecommerce_Store') {
                        // Try a simpler Maven command first with full error output
                        echo "🚀 Testing simple Maven compile"
                        bat script: "mvn compile -e -s ..\\settings.xml", returnStatus: true
                        
                        // Try to run Maven with all error details
                        echo "🚀 Running Maven with full error details"
                        bat script: "mvn clean install -DskipTests -B -e -s ..\\settings.xml > maven_output.log 2>&1", returnStatus: true
                        
                        // Display the log file regardless of success or failure
                        bat "type maven_output.log || echo Could not find log file"
                    }
                }
            }
            post {
                always {
                    echo "📋 Collecting Maven build logs"
                    
                    // Try to fetch any Maven logs that might exist
                    bat script: """
                        if exist Ecommerce_Store\\target\\maven-status (
                            echo Maven status files found:
                            dir Ecommerce_Store\\target\\maven-status /s
                        ) else (
                            echo No Maven status files found
                        )
                    """, returnStatus: true
                }
            }
        }
    }
}

        stage('Test') {
            parallel {
                stage('JUnit') {
                    steps {
                        configFileProvider([configFile(fileId: 'global-settings-xml', targetLocation: 'settings.xml')]) {
                            dir('Ecommerce_Store') {
                                echo '📋 Génération des rapports JUnit'
                                bat 'mvn test -s settings.xml'
                                junit 'target/surefire-reports/*.xml'
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
                        echo '⚙ Exécution des tests de performance (placeholder)'
                    }
                }
            }
        }

        stage('Analyse du code') {
            parallel {
                stage('Checkstyle') {
                    steps {
                        configFileProvider([configFile(fileId: 'global-settings-xml', targetLocation: 'settings.xml')]) {
                            dir('Ecommerce_Store') {
                                bat 'mvn checkstyle:checkstyle -s settings.xml'
                            }
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
                        configFileProvider([configFile(fileId: 'global-settings-xml', targetLocation: 'settings.xml')]) {
                            dir('Ecommerce_Store') {
                                bat 'mvn pmd:pmd -s settings.xml'
                            }
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
                        configFileProvider([configFile(fileId: 'global-settings-xml', targetLocation: 'settings.xml')]) {
                            dir('Ecommerce_Store') {
                                echo '🔎 Analyse SpotBugs'
                                bat 'mvn spotbugs:spotbugs -s settings.xml'
                            }
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
                configFileProvider([configFile(fileId: 'global-settings-xml', targetLocation: 'settings.xml')]) {
                    dir('Ecommerce_Store') {
                        bat 'mvn javadoc:javadoc -s settings.xml'
                    }
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
                        configFileProvider([configFile(fileId: 'global-settings-xml', targetLocation: 'settings.xml')]) {
                            dir('Ecommerce_Store') {
                                bat 'mvn deploy -s settings.xml'
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
