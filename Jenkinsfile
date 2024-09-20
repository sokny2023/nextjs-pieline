pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'nextjs-test1'                 // Docker image name
        DOCKER_TAG = "${env.BUILD_NUMBER}"            // Docker image tag (using Jenkins build number)
        COMPOSE_FILE = 'docker-compose.yml'           // Path to docker-compose file
    }

    stages {
        stage('Prepare Environment') {
            steps {
                script {
                    // Ensure Docker and Docker Compose are installed on the Jenkins agent
                    sh 'docker --version'
                    sh 'docker-compose --version'
                }
            }
        }

        stage('Checkout Code') {
            steps {
                // Pull the latest code from the repository
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image using the Dockerfile in the project root
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Push the Docker image to Docker Hub (requires Docker credentials to be configured in Jenkins)
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    // Use Docker Compose to stop the running application and start a new version
                    sh """
                    docker-compose down
                    docker-compose up -d
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean workspace after pipeline execution
            cleanWs()
        }

        success {
            // Notify if the deployment was successful
            echo "Deployment successful!"
        }

        failure {
            // Notify if the deployment failed
            echo "Deployment failed!"
        }
    }
}
