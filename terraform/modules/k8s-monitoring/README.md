# k8s-monitoring

This module contains resources related to monitoring.

- [Fluent-bit](https://github.com/fluent/helm-charts/tree/main/charts/fluent-bit)
- [OpenSearch](https://github.com/opensearch-project/helm-charts/charts/opensearch)
- [OpenSearch Dashboards](https://github.com/opensearch-project/helm-charts/charts/opensearch-dashboards)
- [Prometheus Operator](https://github.com/prometheus-operator/kube-prometheus)

# Variables:

- `alert_manager_config`: `yaml` encoded as a string that contains the [alert manager config](#alert-manager).
- `lets_encrypt_notification_inbox`: Email to use for notifications about LetsEncrypt. Needs to be a valid email if certificates are enabled.
- `cluster_domain`: Base domain for all monitoring services.
- `enable_monitoring_ingress`: Boolean that determines whether to enable ingress for monitoring services. Defaults to `false`.

# Components

## OpenSearch Dashboard

Cluster logs are forwaded using Fluent-bit to OpenSearch. They can be accessed via the OpenSearch dashboard.

Accessing the dashboard is possible by running the following command within the `control` directory.

```bash
./kubectl --namespace monitoring port-forward --address 0.0.0.0 deployments/opensearch-dashboard-opensearch-dashboards 8001:5601
```

The username is `admin` and the password can be retrieved with:

```bash
./tf output -raw opensearch_dashboard_admin_password
```

After running the command above, the default OpenSearch dashboard will be viewable
in your browser at [http://localhost:8001](http://localhost:8001).

On the first run, you will need to create
an **Index Pattern** for `fluent-bit`. Once done, you will be able to view
the logs in [your discover page](http://localhost:8001/app/discover).

## Grafana

You can view the Grafana dashboard by running the following command within the `control` directory.

```bash
./kubectl --namespace monitoring port-forward --address 0.0.0.0 svc/prometheus-operator-grafana 8001:3000
```

After running the command above, the default Grafana dashboard will be viewable
in your browser at [http://localhost:8001](http://localhost:8001).

Both the username and password for the default user is `admin`.
You will be requested to change it after logging in the first time.

The **Kubernetes Resource Workload** dashboard is loaded by default with more
dashboards available via the sidebar's [Browse](http://localhost:8001/dashboards) item.

For more information about Grafana, visit https://grafana.com.

## Prometheus

View the Prometheus metrics, by running the below within the `control` directory.

```bash
./kubectl --namespace monitoring port-forward --address 0.0.0.0 svc/prometheus-operated 8001:9090
```

After running the command above, the Prometheus UI will be viewable in your
browser at [http://localhost:8001](http://localhost:8001).

For more information about Prometheus, visit https://prometheus.io.

## Alert Manager

**Dashboard**

Within the `control` directory, run:

```bash
./kubectl --namespace monitoring port-forward --address 0.0.0.0 svc/alertmanager-operated 8001:9093
```

After running the command above, the Alert Manager UI will be viewable in your browser at
[http://localhost:8001](http://localhost:8001).

For more information about Alert Manager, visit https://prometheus.io/docs/alerting/latest/alertmanager/.

**Configuration:**

See https://prometheus.io/docs/alerting/latest/configuration/ for extensive documentation.

Alert manager configuration can be change by setting the `alert_manager_config` variable
to a `yaml`-encoded string.

Example configuration to define in the `private.yaml`:

```yaml
TF_VAR_alert_manager_config: |
  receivers:
  - name: "null"
  - name: email
    email_configs:
    - to: 'receiver_mail_id@example.com'
      from: 'mail_id@example.com'
      smarthost: smtp.example.com:587
      auth_username: 'mail_id@example.com'
      auth_identity: 'mail_id@example.com'
      auth_password: 'password'
```

!!! note "Default null route"
    <!-- markdownlint-disable MD046 -->
    Note that `"null"` receiver is required. Due to the way values are merged in helm, this receiver needs to exist otherwise you'll receive `undefined receiver` error. Example:

    ```
    level=error ts=2020-10-23T12:08:02.428Z caller=coordinator.go:124 component=configuration msg="Loading configuration file failed" file=/etc/alertmanager/config/alertmanager.yaml err="undefined receiver \"null\" used in route"
    ```

    Visit this [Github issue](https://github.com/prometheus-community/helm-charts/issues/255) for more details.

# Ingress

## Lets Encrypt email

For expiration emails and to have a record of the owner, set the `lets_encrypt_notification_inbox` value to an email that you control. Certificate generation will **not** work with the default values.

## Domains
The `TF_VAR_cluster_domain` variable contains the base domain used for the monitoring resources.

Ingresses will be created for each of the above as `<SERVICE NAME>.${cluster_domain}`.

- `prometheus.${cluster_domain}`
- `grafana.${cluster_domain}`
- `alert-manager.${cluster_domain}`
- `opensearch-dashboards.${cluster_domain}`

## Enable

Ingress for monitoring services can be enabled by setting the variable `enable_monitoring_ingress` to true.

**Please note that you need to set up DNS before applying the change otherwise the apply will fail.**

## Access

To prohibit unauthorized to these, basic HTTP authentication is set up for extra protection.

The username is `admin` and the password can be obtained with `./tf output -raw monitoring_ingress_password`.

# Output

This module doesn't provide any output.
