pipeline {
    agent { label 'master' }

    triggers {
      upstream(upstreamProjects: "jenkins-build-base", threshold: hudson.model.Result.SUCCESS)
    }

    environment {
        IMAGE_NAME = 'jenkins-build-android'
        IMAGE_VERSION = "1.1"
        SCAN_REGISTRY = "sentinel:5001"
        APPROVED_REGISTRY = "sentinel:5000"
    }

    stages {
        stage('Build Image') {
            steps {
                script {
                    def customImage = docker.build("${IMAGE_NAME}:${IMAGE_VERSION}.${BUILD_NUMBER}", "--network host --no-cache .")
                    docker.withRegistry('https://${SCAN_REGISTRY}') {
                        customImage.push()
                    }
                }
            }
        }

        stage('Scan Image') {
            steps {
                sh 'echo "${SCAN_REGISTRY}/${IMAGE_NAME}:${IMAGE_VERSION}.${BUILD_NUMBER} Dockerfile" > anchore_images'
                anchore 'anchore_images'
            }
        }

        stage('Push Image') {
            steps {
                script {
                    def customImage = docker.image("${IMAGE_NAME}:${IMAGE_VERSION}.${BUILD_NUMBER}")
                    docker.withRegistry('https://${APPROVED_REGISTRY}') {
                        customImage.push()
                        customImage.push('latest')
                    }
                }
            }
        }
    }
}
