pipeline {
    agent any
    stages {
        stage('Build & Test') {
            steps {
                echo 'Running build automation'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Running docker image build'
            }
        }

        stage('Push Image to ECR') {
            steps {
                echo 'Running docker image push'
            }
        }

        stage('Deploy in ECS') {
            steps {
                echo 'Running docker image deploy'
            }
        }
    }
}
