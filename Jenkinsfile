// Jenkinsfile
// Author: Divya Soni
// Course: SWE645 - Assignment 2
// Purpose: CI/CD pipeline for automated build and deployment to Kubernetes

pipeline {
    agent any
    
    environment {
        DOCKER_HUB_REPO = "sonidiv372/studentsurvey645"
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        BUILD_TIMESTAMP = "${new Date().format('yyyyMMdd-HHmmss')}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code from GitHub...'
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh "docker build -t ${DOCKER_HUB_REPO}:${BUILD_TIMESTAMP} ."
                    sh "docker tag ${DOCKER_HUB_REPO}:${BUILD_TIMESTAMP} ${DOCKER_HUB_REPO}:latest"
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    sh "echo ${DOCKER_HUB_CREDENTIALS_PSW} | docker login -u ${DOCKER_HUB_CREDENTIALS_USR} --password-stdin"
                    sh "docker push ${DOCKER_HUB_REPO}:${BUILD_TIMESTAMP}"
                    sh "docker push ${DOCKER_HUB_REPO}:latest"
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes cluster...'
                script {
                    sh "kubectl set image deployment/studentsurvey-deployment studentsurvey=${DOCKER_HUB_REPO}:${BUILD_TIMESTAMP}"
                    sh "kubectl rollout status deployment/studentsurvey-deployment"
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs.'
        }
        always {
            sh 'docker logout'
        }
    }
}
