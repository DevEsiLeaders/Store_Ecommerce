post {
    success {
        echo "[DEBUG] Preparing to send success email..."
        emailext(
            to: 'badrbernane6@gmail.com',
            from: 'badrbernane6@gmail.com', // Updated sender email to match your email
            subject: "✅ Succès Pipeline ${JOB_NAME} #${BUILD_NUMBER}",
            body: """
Le pipeline s'est terminé avec succès.
🔧 Job: ${JOB_NAME}
🔢 Build: #${BUILD_NUMBER}
🔗 URL: ${BUILD_URL}
"""
        )
        echo "[DEBUG] Success email step completed."
    }
    failure {
        echo "[DEBUG] Preparing to send failure email..."
        emailext(
            to: 'badrbernane6@gmail.com',
            from: 'badrbernane6@gmail.com', // Updated sender email to match your email
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
