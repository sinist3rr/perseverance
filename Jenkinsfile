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
                sh 'python tests.py'
                sh 'flake8 app/ --exit-zero --output-file flake8-output.txt'
            }
            post {
               always {
                   junit 'test-reports/*.xml'
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
        always {
          node('master') {
            cleanWs()
          }
        }
    }
}
