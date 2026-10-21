# RabbitMQ Autoscaling Lab

A local Kubernetes lab for exercising RabbitMQ queue workloads and the
observability/autoscaling stack around them. It includes setup scripts for a
Minikube cluster, RabbitMQ, KEDA, Prometheus, and Grafana, plus load-test
helpers and dashboards.

This is a lab environment, not a production deployment. The repo provides the
cluster and monitoring setup; add your own `ScaledObject` and worker manifests
for the queue workload you want to test.

## What this covers

- A single-node RabbitMQ cluster via the RabbitMQ Cluster Operator
- KEDA installation for event-driven autoscaling
- Prometheus Operator / kube-prometheus-stack
- RabbitMQ dashboards and alerting rules
- Perf-test load generation

## Local environment

- Windows 11
- Memory: 8GB
- WSL 2
- Docker Desktop
- kubectl
- Minikube

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

Get started by deploying Scaled Objects to your cluster:

- Information about Scaled Objects: <https://keda.sh/docs/latest/concepts/>
- Samples: <https://github.com/kedacore/samples>

Get information about the deployed ScaledObjects:

```bash
kubectl get scaledobject [--namespace <namespace>]
```

Get details about a deployed ScaledObject:

```bash
kubectl describe scaledobject <scaled-object-name> [--namespace <namespace>]
```

Get information about the deployed TriggerAuthentications:

```bash
kubectl get triggerauthentication [--namespace <namespace>]
```

Get details about a TriggerAuthentication:

```bash
kubectl describe triggerauthentication <trigger-authentication-name> [--namespace <namespace>]
```

Get an overview of the Horizontal Pod Autoscalers (HPA) that KEDA is using
behind the scenes:

```bash
kubectl get hpa [--all-namespaces] [--namespace <namespace>]
```

## Repository layout

- `install-*.sh` — install kubectl, Helm, Minikube, Docker, and KEDA
- `quickstart.sh` / `quickstart.ps1` — bring up the monitoring stack
- `prometheus/` — rules, monitors, and an Alertmanager example
- `grafana/dashboards/` — RabbitMQ dashboards
- `perf-test.sh` — run the RabbitMQ perf-test container
- `cleanup.ps1` — remove the lab resources

## Notes

- The Grafana quickstart uses `admin/admin` for local convenience. Change it
  before exposing the UI.
- The perf-test JARs are not committed. Use the
  `pivotalrabbitmq/perf-test` image shown above, or download the JARs from the
  upstream project.

## License

Original scripts and documentation are MIT-licensed; see [LICENSE](LICENSE).
Third-party dashboards, rules, and perf-test HTML retain their upstream
licenses; see [NOTICE.md](NOTICE.md).
