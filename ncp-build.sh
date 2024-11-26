#!/bin/bash
echo BUILD START...
COMMIT_ID=`git rev-parse --short HEAD`
echo Building with gradle...
mkdir -p logs
chmod +x ./gradlew
./gradlew clean build jib -PspringProfile=$SPRING_PROFILES_ACTIVE -PdockerRegistry=$IMAGE_REPO_NAME -PdockerUser=$ACCESS_KEY -PdockerPassword=$SECRET_KEY -PserviceName=$ARGO_APPLICATION -PcommitRev=$COMMIT_ID -Djib.allowInsecureRegistries=true
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] ; then
  echo 'gradle build failed'; exit $EXIT_CODE
fi
echo BUILD END...
