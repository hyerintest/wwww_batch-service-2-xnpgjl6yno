#!/bin/bash
echo "Sonarqube analysis..."
chmod +x ./gradlew
./gradlew sonar -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.projectKey=$PROJECT_KEY -Dsonar.projectName=$PROJECT_KEY -Dsonar.token=$SONAR_TOKEN
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] ; then
  echo 'Sonarqube analysis failed'; exit $EXIT_CODE
fi
sleep 60
curl -u $SONAR_ID:$SONAR_PWD $SONAR_HOST_URL/api/qualitygates/project_status\?projectKey\=$PROJECT_KEY > result.json
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] ; then
  echo 'Sonarqube Quality gates failed'; exit $EXIT_CODE
fi
cat result.json
if [ "$(jq -r '.projectStatus.status' result.json)" = "ERROR" ]; then
  CODEBUILD_BUILD_SUCCEEDING=0
fi
echo Code scan completed on `date`
if [ $CODEBUILD_BUILD_SUCCEEDING -eq 0 ]; then exit 1; fi
set -x