## 清單

- Ingress是一種 API 對象， 其中定義了一些規則使得叢集中的服務可以從叢集外存取。 Ingress 控制器負責符合 Ingress 中所設定的規則。

## `kubectl`

- 顯示清單:
    - 配置: `kubectl config view`
    - 部署: `kubectl get deployments`
    - 事件: `kubectl get events`
    - 服務: `kubectl get services`
    - Pods: `kubectl get pods`

- 列出所有 pods:
    - `kubectl get po -A`

- 建立部署:
    - `kubectl create deployment DEPLOYMENT`
    - 例子: `kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1`
    - 例子: `kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0`

- 描述部署:
    - 例子: `kubectl describe deployment hello-minikube`

- 從url應用 pod:
    - 例子 `kubectl apply -f https://k8s.io/examples/application/shell-demo.yaml`

- 在docker容器中運行 bash:
    - 例子: `kubectl exec -it shell-demo -- bash`

- 將pod暴露到本地網絡:
    - `kubectl expose deployment DEPLOYMENT --type=LoadBalancer --port=PORT`
    - 例子: `kubectl expose deployment hello-node --type=LoadBalancer --port=8080`

- 打掃乾淨:
    - `kubectl delete service hello-node`
    - `kubectl delete deployment hello-node`

- 創建代理: `kubectl proxy -p 9000`

- 顯示pod標識值:
    - `kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`

## `minikube`

- 清單:
    - 添加在: `minikube addons list`
    - 服務(包括本地ip): `minikube service list`

- 打掃乾淨:
    - `minikube delete`

- 啟用指標伺服器插件: `minikube addons enable metrics-server`

- 從不同範圍的連接埠開始:
    - `minikube start --extra-config=apiserver.service-node-port-range=80-30000`
