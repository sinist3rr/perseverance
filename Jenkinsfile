pipeline {
    agent none
    environment {
        AWS_ECR_REGION = 'eu-west-3'
        AWS_ECR_URL = '466897917695.dkr.ecr.eu-west-3.amazonaws.com/python-flask-app-production-ecr'
        AWS_ECS_SERVICE = 'python-flask-app-production-ecs-service'
        AWS_ECS_CLUSTER = 'python-flask-app-production-cluster'
        API_KEY = credentials('nasa_api_key')
        TF_IN_AUTOMATION = 'true'
        TF_VAR_nasa_api_key = "${API_KEY}"
    }
    stages {
        stage('Terraform Init') {
           agent any
           steps {
               withAWS(credentials: 'aws_terraform') {
                  dir("${env.WORKSPACE}/terraform"){
                      ansiColor('xterm') {
                          sh "/usr/local/bin/terraform init -input=false"
                      }
                  }
               }
           }
        }
        stage('Terraform Plan') {
           agent any
           steps {
               withAWS(credentials: 'aws_terraform') {
                  dir("${env.WORKSPACE}/terraform"){
                      ansiColor('xterm') {
                          sh "/usr/local/bin/terraform plan -out=tfplan -input=false -var-file='dev.tfvars'"
                      }
                 }
               }
           }
        }
        stage('Test') {
            agent {
              docker 'sinist3r/python-alpine-flask'
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
                  docker.image("${AWS_ECR_URL}:${BUILD_NUMBER}").push()
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
                  sh(returnStdout: true, script: "aws ecs update-service --cluster ${AWS_ECS_CLUSTER} --service ${AWS_ECS_SERVICE} --force-new-deployment")
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
            sh "docker rmi ${AWS_ECR_URL}:latest"
          }
        }
    }
}
