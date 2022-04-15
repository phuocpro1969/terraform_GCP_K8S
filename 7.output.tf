output "instance_lb_ip_addr" {
  value       = google_compute_instance.lb-instance.network_interface.0.access_config.0.nat_ip
  description = "loadbalancer public ip"
  depends_on = [
    google_compute_instance.lb-instance
  ]
}

output "instance_master_ip_addr" {
  value       = google_compute_instance.master-instance.*.network_interface.0.access_config.0.nat_ip
  description = "master public ips"

  depends_on = [
    google_compute_instance.master-instance
  ]
}

output "instance_worker_ip_addr" {
  value       = google_compute_instance.worker-instance.*.network_interface.0.network_ip
  description = "worker private ips"

  depends_on = [
    google_compute_instance.worker-instance
  ]
}

output "resources_master_provisilboner_1" {
  value       = "install k8s successfully"
  description = "install k8s"
  depends_on = [
    null_resource.only_master_1_provisilboner
  ]
}


