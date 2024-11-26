#!/bin/bash
echo POST START...
COMMIT_ID=`git rev-parse --short HEAD`
git clone https://$USER_NAME:$USER_PASSWORD@${NCP_BASE_HELM_URL}/${ACCOUNT}/${GROUP_NAME}_HelmChart.git
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] ; then
  echo 'git clone failed'; exit $EXIT_CODE
fi
cd ${GROUP_NAME}_HelmChart/${STAGE_NAME}/${SERVICE_NAME}
find . -name values.yaml -type f -exec sed -i 's/^\(\s*tag\s*:\s*\).*/\1'$ARGO_APPLICATION-$COMMIT_ID'/' {} \;
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] ; then
  echo 'find failed'; exit $EXIT_CODE
fi
git config --global user.email "info@twolinecode.com"
git config --global user.name "sourceCommit-runner"
git add ./values.yaml
git commit --allow-empty -m "Pushed Helm Chart:$ARGO_APPLICATION-$COMMIT_ID"
while :
do
  git pull --rebase origin master
  if git push origin master
  then
    break
  fi
done
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] ; then
  echo 'git push failed'; exit $EXIT_CODE
fi
echo Apply k8s...
helm template ../Common > common.yaml
kubectl --kubeconfig ../${KUBECONFIG} apply -f common.yaml
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] ; then
  echo 'kubectl apply common.yaml failed'; exit $EXIT_CODE
fi
ENDPOINT=$(kubectl --kubeconfig ../${KUBECONFIG} get ing -n tlc-support -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
PASSWORD=$(kubectl --kubeconfig ../${KUBECONFIG} get secret argocd-initial-admin-secret -n tlc-support -o jsonpath='{.data.password}' | base64 -d)
echo y | argocd login $ENDPOINT --grpc-web-root-path argocd --username admin --password $PASSWORD
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] ; then
  echo 'ArgoCD login failed'; exit $EXIT_CODE
fi
argocd app get ${ARGO_APPLICATION} --refresh
argocd app sync ${ARGO_APPLICATION}
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] ; then
  echo 'ArgoCD sync failed'; exit $EXIT_CODE
fi
echo POST END...
