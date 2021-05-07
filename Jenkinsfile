pipeline {
    agent none
    environment {
        AWS_ECR_REGION = 'eu-west-3'
        AWS_ECR_URL = '466897917695.dkr.ecr.eu-west-3.amazonaws.com/python-flask-app-production-ecr'
        AWS_ECS_SERVICE = 'python-flask-app-production-ecs-service'
        AWS_ECS_CLUSTER = 'python-flask-app-production-cluster'
    }
    stages {
        stage('Test') {
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
                withAWS(region: "${AWS_ECR_REGION}", credentials: 'aws_ecr') {
                  sh('#!/bin/sh -e\n' + "${ecrLogin()}") // hide logging
                  docker.image("${AWS_ECR_URL}:${BUILD_NUMBER}").push('latest')
                }
              }
            }
        }

        stage('Deploy in ECS') {
            agent any
            steps {
              script {
                withAWS(region: "${AWS_ECR_REGION}", credentials: 'aws_ecr') {
                  def updateService = "aws ecs update-service --cluster ${AWS_ECS_CLUSTER} --service ${AWS_ECS_SERVICE} --force-new-deployment"
                  def runUpdateService = sh(returnStdout: true, script: updateService)
                  // sh("aws ecs update-service --cluster ${AWS_ECS_CLUSTER} --service ${AWS_ECS_SERVICE} --force-new-deployment")
               }
              }
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
