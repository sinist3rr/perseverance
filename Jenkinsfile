pipeline {
    agent none
    stages {
        stage('Build & Test') {
            agent {
              docker {
                    image "python:3.6.1"
                    args "e PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/jenkins/workspace/flask_pipe/.local/"
              }
            }
            steps {
              withEnv(["HOME=${env.WORKSPACE}"]) {
                sh 'pip install -r requirements.txt --user'
                sh 'env'
                sh 'flake8 app/ --exit-zero --output-file flake8-output.txt'
                sh 'flake8_junit flake8-output.txt flake8-output.xml'
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
}
