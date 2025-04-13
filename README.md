# GPSD Kafka Helm Chart

This Helm chart deploys Apache Kafka with KRaft mode (without ZooKeeper) and optionally a Kafka UI for management purposes.

## Prerequisites

- Kubernetes cluster
- Helm 3 installed
- kubectl configured to communicate with your cluster

## Configuration

The following table lists the configurable parameters of the Kafka chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace` | Kubernetes namespace to deploy into | `gpsd` |
| `replicaCount` | Number of Kafka broker replicas | `1` |
| `broker.image.repository` | Kafka broker image repository | `apache/kafka` |
| `broker.image.tag` | Kafka broker image tag | `latest` |
| `broker.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `broker.persistence.enabled` | Enable persistence for Kafka logs | `true` |
| `broker.persistence.size` | Size of the persistent volume for Kafka | `10Gi` |
| `broker.config.brokerId` | Kafka broker ID | `1` |
| `broker.config.clusterId` | Kafka cluster ID | `MkU3OEVBNTcwNTJENDM2Qk` |
| `kafkaUi.enabled` | Enable Kafka UI deployment | `true` |
| `kafkaUi.image.repository` | Kafka UI image repository | `provectuslabs/kafka-ui` |
| `kafkaUi.image.tag` | Kafka UI image tag | `latest` |
| `serviceAccount.create` | Create a service account | `true` |
| `serviceAccount.name` | Name of the service account | `gpsd-kafka-sa` |

## Installation

```bash
# Install the chart with the release name "demo"
helm install demo ./helm -n gpsd
```

## Accessing Kafka

Within the cluster, Kafka will be accessible at:

```
<release-name>-gpsd-kafka-broker:9092
```

For example, if your release name is "demo", the address would be:

```
demo-gpsd-kafka-broker:9092
```

## Accessing the Kafka UI

If Kafka UI is enabled, it will be accessible within the cluster at:

```
<release-name>-gpsd-kafka-ui:8080
```

To access it from outside the cluster, you may need to set up port-forwarding:

```bash
kubectl port-forward svc/<release-name>-gpsd-kafka-ui 8080:8080 -n gpsd
```

Then open your browser and navigate to: http://localhost:8080

## Persistence

The chart mounts a Persistent Volume for the Kafka broker by default. To disable this functionality, set:

```yaml
broker:
  persistence:
    enabled: false
```

## Uninstalling

To remove the Kafka deployment:

```bash
helm uninstall demo -n gpsd
```

Note: This will not remove Persistent Volume Claims. To remove them:

```bash
kubectl delete pvc <release-name>-gpsd-kafka-broker-pvc -n gpsd
```