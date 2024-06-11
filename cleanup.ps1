#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"
$DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition

$KUBE_PROMETHEUS_STACK_NAME = 'prom'
$KUBE_PROMETHEUS_STACK_NAMESPACE = 'kube-prometheus'

Write-Host "Uninstalling kube-prometheus-stack Chart..." -ForegroundColor red
helm uninstall $KUBE_PROMETHEUS_STACK_NAME --namespace $KUBE_PROMETHEUS_STACK_NAMESPACE

Write-Host "Removing ServiceMonitor and PodMonitor..." -ForegroundColor red
kubectl -n $KUBE_PROMETHEUS_STACK_NAMESPACE delete -f "$DIR/prometheus/monitors/"

Write-Host "Removing Prometheus rules..." -ForegroundColor red
kubectl -n $KUBE_PROMetHEUS_STACK_NAMESPACE delete -R -f "$DIR/prometheus/rules/"

Write-Host "Removing RabbitMQ Grafana Dashboards..." -ForegroundColor red
kubectl -n $KUBE_PROMETHEUS_STACK_NAMESPACE delete -f "$DIR/grafana/dashboards/"

Write-Host "Removing RabbitMQ Cluster Operator..." -ForegroundColor red
kubectl delete -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"

Write-Host "Removing Prometheus Helm Chart Repository..." -ForegroundColor red
helm repo remove prometheus-community

Write-Host "Cleanup completed." -ForegroundColor green
