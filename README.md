# Tugas Akhir

## Local Environment

- Windows 11
- Memory: 8GB
- CPU:
- WSL 2
- Docker Desktop
- kubectl
- minikube

## Setup RabbitMQ

1. Install the RabbitMQ Cluster Operator

   ```pwsh
   kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
   ```

2. Create hello-world RabbitMQ cluster

   ```pwsh
   kubectl apply -f "https://raw.githubusercontent.com/rabbitmq/cluster-operator/main/docs/examples/hello-world/rabbitmq.yaml"
   ```

3. Access The Management UI

   ```pwsh
   username="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.username}' | base64 --decode)"
   echo "username: $username"
   password="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.password}' | base64 --decode)"
   echo "password: $password"

   kubectl port-forward "service/hello-world" 15672
   ```

4. Connect An Application To The Cluster

   ```pwsh
   username="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.username}' | base64 --decode)"
   password="$(kubectl get secret hello-world-default-user -o jsonpath='{.data.password}' | base64 --decode)"
   service="$(kubectl get service hello-world -o jsonpath='{.spec.clusterIP}')"

   kubectl run perf-test --image=pivotalrabbitmq/perf-test -- --uri amqp://$username:$password@$service
   ```

## Setup Monitoring

- <https://prometheus-operator.dev/docs/prologue/quick-start/>
- <https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack>
- <https://github.com/rabbitmq/cluster-operator/blob/main/observability/quickstart.sh>

Get started by deploying Scaled Objects to your cluster: - Information about Scaled Objects : <https://keda.sh/docs/latest/concepts/> - Samples: <https://github.com/kedacore/samples>

Get information about the deployed ScaledObjects:
kubectl get scaledobject [--namespace <namespace>]

Get details about a deployed ScaledObject:
kubectl describe scaledobject <scaled-object-name> [--namespace <namespace>]

Get information about the deployed ScaledObjects:
kubectl get triggerauthentication [--namespace <namespace>]

Get details about a deployed ScaledObject:
kubectl describe triggerauthentication <trigger-authentication-name> [--namespace <namespace>]

Get an overview of the Horizontal Pod Autoscalers (HPA) that KEDA is using behind the scenes:
kubectl get hpa [--all-namespaces] [--namespace <namespace>]
