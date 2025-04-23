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
                    echo '🐞 Analyse avec FindBugs pour détecter les bugs potentiels'
                }
            }
        }
        stage('FixBugs') {
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
