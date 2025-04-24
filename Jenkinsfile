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
                    echo "🔍 Checking Ecommerce_Store directory content"
                    bat "dir Ecommerce_Store"
                    
                    // Check if pom.xml exists in the Ecommerce_Store directory
                    bat "if exist Ecommerce_Store\\pom.xml (echo POM file found) else (echo POM file NOT found)"
                }
                
                configFileProvider([configFile(fileId: 'global-settings-xml', targetLocation: 'settings.xml')]) {
                    // Verify settings.xml content
                    bat "echo Verifying settings.xml content:"
                    bat "type settings.xml | findstr /C:\"repositories\" /C:\"repository\" /C:\"pluginRepositories\""
                    
                    dir('Ecommerce_Store') {
                        // Print current directory to confirm location
                        bat "cd"
                        
                        // Try Maven with verbose output but limited goals first
                        echo "🚀 Running Maven validate with debug output"
                        bat "mvn validate -X -s ..\\settings.xml || echo Maven validate failed"
                        
                        // If validation passes, attempt the full build
                        echo "🚀 Running full Maven build"
                        bat "mvn clean install -DskipTests -s ..\\settings.xml"
                    }
                }
            }
            post {
                failure {
                    echo "❌ Maven build failed - checking POM file content"
                    bat "if exist Ecommerce_Store\\pom.xml (type Ecommerce_Store\\pom.xml) else (echo POM file NOT found)"
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
