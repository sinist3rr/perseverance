pipeline {
    agent none
    environment {
        AWS_ECR_REGION = 'eu-west-3'
        AWS_ECR_URL = '466897917695.dkr.ecr.eu-west-3.amazonaws.com/python-flask-app-production-ecr'
        AWS_ECS_SERVICE = 'python-flask-app-production-ecs-service'
        AWS_ECS_TASK_DEFINITION = 'python-flask-app-task'
        AWS_ECS_COMPATIBILITY = 'FARGATE'
        AWS_ECS_NETWORK_MODE = 'awsvpc'
        AWS_ECS_CPU = '256'
        AWS_ECS_MEMORY = '512'
        AWS_ECS_CLUSTER = 'python-flask-app-production-cluster'
    }
    stages {
        stage('Build & Test') {
            agent {
                dockerfile {
                    filename 'Dockerfile.build'
                }
            }
            steps {
                sh 'python tests.py'
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
              script {
                  docker.build('${AWS_ECR_URL}:${BUILD_NUMBER}')
              }
            }
        }

        stage('Push Image to ECR') {
            agent any
            steps {
              script {
                withAWS(region: 'eu-west-3', credentials: 'aws_ecr') {
                  sh "${ecrLogin()}"
                  docker.image("${AWS_ECR_URL}:${BUILD_NUMBER}").push()
                }
              }
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
            sh "docker rmi ${AWS_ECR_URL}:${BUILD_NUMBER}"
          }
        }
    }
}
