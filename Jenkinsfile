pipeline {
    agent any

    environment {
        IMAGE_NAME = 'nodejs-app'
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
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
                    try {
                        // Log in to AWS ECR
                        echo "Logging in to AWS ECR..."
                        sh '''
                        aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_REPO}"
                        '''

                        // Tag the Docker image
                        echo "Tagging Docker image..."
                        sh "docker tag ${IMAGE_NAME}:latest ${ECR_REPO}:${BUILD_NUMBER}"

                        // Push the Docker image to AWS ECR
                        echo "Pushing Docker image to ECR..."
                        sh "docker push ${ECR_REPO}:${BUILD_NUMBER}"

                        echo "Successfully pushed ${IMAGE_NAME}:${BUILD_NUMBER} to ECR."

                    } catch (Exception e) {
                        // Handle any errors that occur during the process
                        error "Failed to tag or push the image to ECR: ${e.message}"
                    }
                }
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
