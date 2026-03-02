// Jenkinsfile
// Author: Divya Soni
// Course: SWE645 - Assignment 2
// Purpose: CI/CD pipeline for automated build and deployment to Kubernetes

pipeline {
    agent any
    
    environment {
        DOCKER_HUB_REPO = "sonidiv372/studentsurvey645"
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
                sh "docker build -t ${DOCKER_HUB_REPO}:${BUILD_TIMESTAMP} ."
                sh "docker tag ${DOCKER_HUB_REPO}:${BUILD_TIMESTAMP} ${DOCKER_HUB_REPO}:latest"
            }
        }
        
        stage('Login to Docker Hub') {
            steps {
                echo 'Logging into Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                sh "docker push ${DOCKER_HUB_REPO}:${BUILD_TIMESTAMP}"
                sh "docker push ${DOCKER_HUB_REPO}:latest"
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes cluster...'
                sh "kubectl set image deployment/studentsurvey-deployment studentsurvey=${DOCKER_HUB_REPO}:${BUILD_TIMESTAMP}"
                sh "kubectl rollout status deployment/studentsurvey-deployment"
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
