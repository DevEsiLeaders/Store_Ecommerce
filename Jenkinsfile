pipeline {
    agent any
    stages {
        stage('Send Test Email') {
            steps {
                emailext(
                    to: 'badrbernane6@gmail.com',
                    from: 'badrbernane6@domain.com', // Must match your SMTP account
                    subject: "Test Email",
                    body: "This is a minimal test email from Jenkins pipeline."
                )
            }
        }
    }
}
