pipeline {
    agent none
    parameters {
    password (name: 'AWS_ACCESS_KEY_ID')
    password (name: 'AWS_SECRET_ACCESS_KEY')
    }
    environment {
        AWS_ECR_REGION = 'eu-west-3'
        AWS_ECR_URL = '466897917695.dkr.ecr.eu-west-3.amazonaws.com/python-flask-app-production-ecr'
        AWS_ECS_SERVICE = 'python-flask-app-production-ecs-service'
        AWS_ECS_CLUSTER = 'python-flask-app-production-cluster'
        API_KEY = credentials('nasa_api_key')
        TF_WORKSPACE = 'dev' //Sets the Terraform Workspace
        TF_IN_AUTOMATION = 'true'
        AWS_ACCESS_KEY_ID = "${params.AWS_ACCESS_KEY_ID}"
        AWS_SECRET_ACCESS_KEY = "${params.AWS_SECRET_ACCESS_KEY}"
    }
    stages {
        stage('Terraform Init') {
           agent any
           steps {
               sh "cd terraform/"
               sh "terraform init -input=false"
           }
        }
        stage('Terraform Plan') {
           agent any
           steps {
               sh "cd terraform/"
               sh "terraform plan -out=tfplan -input=false -var-file='dev.tfvars'"
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
