pipeline {
    agent any
    stages {
        stage('Send Test Email') {
            steps {
                emailext(
                    to: 'yourRecipient@domain.com',
                    from: 'yourSMTPaccount@gmail.com',
                    subject: "Jenkins Email Test",
                    body: "Testing the Jenkins email configuration."
                )
            }
        }
    }
}
