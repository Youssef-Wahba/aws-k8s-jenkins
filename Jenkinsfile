pipeline {
    agent any

    environment {
        IMAGE_NAME = credentials("IMAGE_NAME")
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        AWS_REGION = credentials("AWS_REGION")
        AWS_ACCESS_KEY_ID = credentials("AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY = credentials("AWS_SECRET_ACCESS_KEY")
        AWS_ACCOUNT_ID = credentials("AWS_ACCOUNT_ID")
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
        KUBECONFIG_PATH = "${env.WORKSPACE}/kubeconfig"  // Set path for KubeConfig
    }

    stages {
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
                    // Log in to ECR
                    echo "Logging in to AWS ECR..."
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    """

                    // Tag the Docker image
                    echo "Tagging Docker image..."
                    sh "docker tag ${IMAGE_NAME}:latest ${ECR_REPO}:${BUILD_NUMBER}"

                    // Push the Docker image to AWS ECR
                    echo "Pushing Docker image to ECR..."
                    sh "docker push ${ECR_REPO}:${BUILD_NUMBER}"

                    echo "Successfully pushed ${IMAGE_NAME}:${BUILD_NUMBER} to ECR."
                }
            }
        }

        stage('Setup KubeConfig') {
                steps {
                    script {
                        withCredentials([file(credentialsId: 'K3S_KUBECONFIG', variable: 'KUBECONFIG_FILE')]) {
                            sh """
                                echo 'Setting up kubeconfig...'
                                cp ${KUBECONFIG_FILE} ${KUBECONFIG_PATH}
                                env.KUBECONFIG = KUBECONFIG_PATH
                            """
                        }
                    }
                }
            }

        stage('Apply Kubernetes Manifests') {
            steps {
                script {
                    sh """
                        kubectl set image deployment/${IMAGE_NAME} ${IMAGE_NAME}=${ECR_REPO}:${BUILD_NUMBER} --namespace nginx-namespace
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                        kubectl apply -f k8s/hpa.yaml
                    """
                }
            }
        }   
        
        stage('Print Logs') {
            steps {
                script {
                    echo "Fetching logs for app=nodejs-app in nginx-namespace..."
                    sh """
                        kubectl logs -n nginx-namespace -l app=nodejs-app --all-containers=true
                    """
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}