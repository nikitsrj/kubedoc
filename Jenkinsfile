pipeline {
        agent any

        parameters {
                 string(name: 'env', defaultValue: 'Deploy', description: 'Development Environment')
                   }

        stages {
                
                stage('Building_Image') {
                agent { label 'master' }
                steps {
                   sh '''
                         cd ${WORKSPACE}
                         REPO="ecr-k8s-app"
                         #Build container images using Dockerfile
                         docker build --no-cache -t ${REPO}:${BUILD_NUMBER} .
                       '''
                     }
                 }
                stage('Pushing_Image_To_ECR') {
                agent { label 'master' }
                steps {
                   sh '''
                         REG_ADDRESS="230367374156.dkr.ecr.ap-southeast-2.amazonaws.com"
                         REPO="ecr-k8s-app"
                         #Tag the build with BUILD_NUMBER version
                         docker tag ${REPO}:${BUILD_NUMBER} ${REG_ADDRESS}/${REPO}:${BUILD_NUMBER}
                         #Publish image
                         docker push ${REG_ADDRESS}/${REPO}:${BUILD_NUMBER}
                      '''
                       }
                   }

                stage('Deploy_In_Kubernetes') {
                agent { label 'master' }
                steps {
                      sshagent ( credentials: []) {
sh '''
echo "Tag=${BUILD_NUMBER}" > sshenv
echo "target=${env}" >> sshenv
scp sshenv admin@52.63.194.198:~/.ssh/environment
ssh -T -o StrictHostKeyChecking=no -l admin 52.63.194.198 <<'EOF'
DEPLOYMENT_NAME="k8s-app"
CONTAINER_NAME="k8s-app"
NEW_DOCKER_IMAGE="230367374156.dkr.ecr.ap-southeast-2.amazonaws.com/ecr-k8s-app:${Tag}"
if [ "${target}" = "NoDeploy" ]
then
  echo "No deployment to K8s"
else
kubectl set image deployment/$DEPLOYMENT_NAME $CONTAINER_NAME=$NEW_DOCKER_IMAGE
kubectl rollout status deployment $DEPLOYMENT_NAME
fi
EOF'''
                       }
                     }
                 }
          }
}
