pipeline {
    agent any
    stages {
        stage('Test Email') {
            steps {
                emailext(
                    to: 'yourRecipient@domain.com',
                    from: 'yourVerifiedSMTP@domain.com',
                    subject: "Test Email from Jenkins Pipeline",
                    body: "This is a test email from a minimal Jenkins Pipeline."
                )
            }
        }
    }
}
