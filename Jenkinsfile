pipeline {
    agent any
    stages {
        stage('Send Test Email') {
            steps {
                emailext(
                    to: 'badrbernane6@gmail.com',
                    from: 'badrbernane6@gmail.com',
                    subject: "Jenkins Email Test",
                    body: "Testing the Jenkins email configuration."
                )
            }
        }
    }
}
