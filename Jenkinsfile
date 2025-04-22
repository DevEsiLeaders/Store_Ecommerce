pipeline {
    agent any

    tools {
        maven 'maven'
        jdk   'JDK'
    }

    triggers {
        githubPush()
    }

    environment {
        // Fully qualified image name (including your DockerHub namespace)
        DOCKER_HUB_REPO      = "sohayb-elbakali/ecommerce-store"
        // Credentials ID for your DockerHub username/password
        DOCKERHUB_CREDENTIALS = "dockerhub-credentials"
    }

    stages {
        stage('Start') {
            steps {
                echo "🚀 Starting CI/CD pipeline"
            }
        }

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[ name: '*/develop' ]],
                    userRemoteConfigs: [[
                        url:           'https://github.com/Badrbernane/Store_Ecommerce.git',
                        credentialsId: 'github-token'
                    ]]
                ])
            }
        }

        stage('Build & Test') {
            parallel {
                stage('Maven Build') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn clean install -DskipTests'
                        }
                    }
                }
                stage('JUnit Tests') {
                    steps {
                        dir('Ecommerce_Store') {
                            bat 'mvn test'
                            junit 'target/surefire-reports/*.xml'
                        }
                    }
                }
            }
        }

        stage('Static Analysis') {
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
                                reportDir:   'Ecommerce_Store/target/site',
                                reportFiles: 'checkstyle.html',
                                reportName:  'Checkstyle Report',
                                keepAll:     true
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
                                reportDir:   'Ecommerce_Store/target/site',
                                reportFiles: 'pmd.html',
                                reportName:  'PMD Report',
                                keepAll:     true
                            ])
                        }
                    }
                }
            }
        }

        stage('Package & Archive') {
            steps {
                dir('Ecommerce_Store') {
                    bat 'mvn package -DskipTests'
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }

        stage('Docker Debug') {
            steps {
                echo "🔍 Docker CLI version & environment"
                bat 'docker version'
                bat 'docker info'
                echo "🔍 Local images before build"
                bat 'docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}"'
            }
        }

        stage('Deploy Docker') {
            steps {
                dir('Ecommerce_Store') {
                    script {
                        def tag        = env.BUILD_NUMBER
                        def fullImage  = "${DOCKER_HUB_REPO}:${tag}"
                        boolean pushed = false
                        int     maxTry = 3
                        int     attempt

                        // Build
                        try {
                            echo "🔧 Building Docker image ${fullImage}"
                            docker.build(fullImage)
                            echo "✅ Built ${fullImage}"
                        } catch (err) {
                            echo "❌ Build failed: ${err}"
                        }

                        // Credentials + login/push loop
                        withCredentials([usernamePassword(
                            credentialsId: DOCKERHUB_CREDENTIALS,
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )]) {
                            for (attempt = 1; attempt <= maxTry; attempt++) {
                                echo "🚀 Push attempt ${attempt}/${maxTry}"
                                try {
                                    // Login
                                    bat """
                                        echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                                    """
                                    // Push
                                    bat "docker push ${fullImage}"
                                    echo "✅ Push succeeded on attempt ${attempt}"
                                    pushed = true
                                    break
                                } catch (err) {
                                    echo "⚠️ Push failed on attempt ${attempt}: ${err}"
                                    // list images for debugging
                                    bat 'docker images --format "{{.Repository}}:{{.Tag}}\t{{.ID}}"'
                                    if (attempt < maxTry) {
                                        echo "⏳ Waiting 5s before retry..."
                                        sleep time: 5, unit: 'SECONDS'
                                    }
                                }
                            }

                            if (!pushed) {
                                echo "❗ All ${maxTry} push attempts failed; skipping push without failing pipeline."
                            }
                        }

                        // Final debug
                        echo "🔍 Local images after push attempts"
                        bat 'docker images --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}"'
                    }
                }
            }
        }

        stage('Finish') {
            steps {
                echo "✅ Pipeline completed"
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
