#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"
$DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host "Initializing Prometheus Helm Chart Repository..." -ForegroundColor green
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# helm search repo prometheus-community/kube-prometheus-stack

Write-Host "Installing kube-prometheus-stack Chart..." -ForegroundColor green
$KUBE_PROMETHEUS_STACK_VERSION = ''
$KUBE_PROMETHEUS_STACK_NAME = 'prom'
$KUBE_PROMETHEUS_STACK_NAMESPACE = 'kube-prometheus'

helm repo update prometheus-community
helm upgrade $KUBE_PROMETHEUS_STACK_NAME prometheus-community/kube-prometheus-stack `
    --version $KUBE_PROMETHEUS_STACK_VERSION `
    --install `
    --namespace $KUBE_PROMETHEUS_STACK_NAMESPACE `
    --create-namespace `
    --set "defaultRules.create=false" `
    --set "nodeExporter.enabled=false" `
    --set "prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false" `
    --set "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false" `
    --set "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false" `
    --set "prometheus.prometheusSpec.probeSelectorNilUsesHelmValues=false" `
    --set "alertmanager.alertmanagerSpec.useExistingSecret=true" `
    --set "grafana.env.GF_INSTALL_PLUGINS=flant-statusmap-panel" `
    --set "grafana.adminPassword=admin"

Write-Host "Installing ServiceMonitor and PodMonitor.." -ForegroundColor green
kubectl -n $KUBE_PROMETHEUS_STACK_NAMESPACE apply -f "$DIR/prometheus/monitors/"

Write-Host "Installing Prometheus rules..." -ForegroundColor green
kubectl -n $KUBE_PROMETHEUS_STACK_NAMESPACE apply -R -f "$DIR/prometheus/rules/"

Write-Host "Installing RabbitMQ Grafana Dashboards..." -ForegroundColor green
kubectl -n $KUBE_PROMETHEUS_STACK_NAMESPACE apply -f "$DIR/grafana/dashboards/"

Write-Host "Installing RabbitMQ Cluster Operator..." -ForegroundColor green
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

Write-Host "To open Prometheus UI execute:"
Write-Host "kubectl -n $KUBE_PROMETHEUS_STACK_NAMESPACE port-forward svc/${KUBE_PROMETHEUS_STACK_NAME}-kube-prometheus-stack-prometheus 9090"
Write-Host "and open your browser at http://localhost:9090" -ForegroundColor green

Write-Host "To open Alertmanager UI execute:"
Write-Host "kubectl -n $KUBE_PROMETHEUS_STACK_NAMESPACE port-forward svc/${KUBE_PROMETHEUS_STACK_NAME}-kube-prometheus-stack-alertmanager 9093"
Write-Host "and open your browser at http://localhost:9093" -ForegroundColor green

Write-Host "To open Grafana UI execute:"
Write-Host "kubectl -n $KUBE_PROMETHEUS_STACK_NAMESPACE port-forward svc/${KUBE_PROMETHEUS_STACK_NAME}-grafana 3000:80"
Write-Host "and open your browser at http://localhost:3000" -ForegroundColor green
Write-Host "username: admin, password: admin"
