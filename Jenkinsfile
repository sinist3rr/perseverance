pipeline {
    agent none
    stages {
        stage('Build & Test') {
            agent {
                dockerfile {
                    filename 'Dockerfile.build'
                }
            }
            steps {
                sh 'flake8 app/ --exit-zero --output-file flake8-output.txt'
                sh 'flake8_junit flake8-output.txt flake8-output.xml'
            }
            post {
               always {
                   junit 'flake8-output.xml'
               }
            }
        }

        stage('Build Docker Image') {
            agent any
            steps {
                echo 'Running docker image build'
            }
        }

        stage('Push Image to ECR') {
            agent any
            steps {
                echo 'Running docker image push'
            }
        }

        stage('Deploy in ECS') {
            agent any
            steps {
                echo 'Running docker image deploy'
            }
        }
    }
    post {
        agent any
        always {
            cleanWs()
        }
    }
}
