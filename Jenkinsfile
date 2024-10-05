pipeline {
    agent any

    environment {
        IMAGE_NAME = 'nodejs-dns-resolver'
    }

    stages {
        stage('Setup Secrets') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'AWS_REGION', variable: 'AWS_REGION'),
                        string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
                        string(credentialsId: 'ECR_REPO', variable: 'ECR_REPO'),
                        // file(credentialsId: 'KUBE_CONFIG', variable: 'KUBECONFIG')
                    ]) {
                        echo 'AWS and Kubernetes credentials loaded as environment variables.'
                    }
                }
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Youssef-Wahba/aws-k8s-jenkins.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:latest")
                }
            }
        }

        stage('Tag and Push to ECR') {
            steps {
                script {
                    // Log in to AWS ECR
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                    '''
                    // Tag the Docker image
                    sh "docker tag ${IMAGE_NAME}:latest ${ECR_REPO}:${BUILD_NUMBER}"

                    // Push the Docker image to AWS ECR
                    sh "docker push ${ECR_REPO}:${BUILD_NUMBER}"
                }
            }
        }

        // stage('Deploy to Kubernetes') {
        //     steps {
        //         script {
        //             // Use the kubeconfig credentials to apply Kubernetes manifests
        //             withKubeConfig([credentialsId: 'KUBE_CONFIG', path: '~/.kube/config']) {
        //                 // Update the Kubernetes deployment with the new Docker image
        //                 sh "kubectl set image deployment/${IMAGE_NAME} ${IMAGE_NAME}=${ECR_REPO}:${BUILD_NUMBER} --namespace default"
        //                 sh 'kubectl apply -f k8s/deployment.yaml'
        //                 sh 'kubectl apply -f k8s/service.yaml'
        //                 sh 'kubectl apply -f k8s/ingress.yaml'
        //             }
        //         }
        //     }
        // }
    }

    post {
        always {
            cleanWs()  // Clean workspace after build
        }
    }
}
