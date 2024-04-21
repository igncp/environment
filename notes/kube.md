## 清單

- Ingress是一種 API 對象， 其中定義了一些規則使得叢集中的服務可以從叢集外存取。 Ingress 控制器負責符合 Ingress 中所設定的規則。

## `kubeadm`

### 設定集群

#### 準備基礎虛擬機

- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
- https://hbayraktar.medium.com/how-to-install-kubernetes-cluster-on-ubuntu-22-04-step-by-step-guide-7dbf7e8f5f99
- 停用 swap, 安裝 docker
- 橋接網路流量
```bash
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# 設定 containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo kubeadm config images pull

# 安裝 helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh && rm ./get_helm.sh

cat >>~/.bash_profile <<"EOF"
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
EOF
```

### 主節點

- `kubeadm init --pod-network-cidr=10.244.0.0/16`: flannel 需要 `--pod-network-cidr`
- 安裝 flannel: https://github.com/flannel-io/flannel?tab=readme-ov-file#deploying-flannel-manually

## ArgoCD

- https://argo-cd.readthedocs.io/en/stable/getting_started/
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# 公開 UI（更改“IP”）
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer", "externalIPs": ["IP"]}}'
# 取得第一個密碼（也可以使用 argo cli 完成）
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

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

- 轉送連接埠並公開它
    - `kubectl port-forward --address 0.0.0.0 service/guestbook-ui 4000:80`

- 將服務匯出為 yaml 文件
    - `k -n argocd get service argocd-server -o yaml`

- 設定預設storageclass
    - `kubectl patch storageclass STORAGE_CLASS_NAME -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`

## `minikube`

- 清單:
    - 添加在: `minikube addons list`
    - 服務(包括本地ip): `minikube service list`

- 打掃乾淨:
    - `minikube delete`

- 啟用指標伺服器插件: `minikube addons enable metrics-server`

- 從不同範圍的連接埠開始:
    - `minikube start --extra-config=apiserver.service-node-port-range=80-30000`
