pipeline {
    agent any

    environment {
        GIT_REPO_URL = 'https://github.com/Badrbernane/Store_Ecommerce.git'
        BRANCHE      = 'develop'
        CREDENTIALS  = 'github-token'
    }

    stages {
        stage('🧪 TEST GIT CHECKOUT') {
            steps {
                echo "🔍 Début du test GIT checkout sur la branche ${BRANCHE}"
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${BRANCHE}"]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [
                        [$class: 'CloneOption', depth: 1, noTags: true, shallow: true]
                    ],
                    userRemoteConfigs: [[
                        url: "${GIT_REPO_URL}",
                        credentialsId: "${CREDENTIALS}",
                        refspec: "+refs/heads/${BRANCHE}:refs/remotes/origin/${BRANCHE}"
                    ]]
                ])
                echo "✅ Clonage terminé avec succès !"
            }
        }

        stage('🗂️ Liste fichiers clonés') {
            steps {
                bat 'dir'
                bat 'cd Ecommerce_Store && dir'
            }
        }
    }

    post {
        always {
            echo '🧹 Nettoyage du workspace...'
            cleanWs()
        }
    }
}

