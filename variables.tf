variable "admin_password" {
    description = "Admin password for Citrix Worker VM"
    type = string
    sensitive = true
}


variable "citrix_workers" {
  description = "Liste der Citrix Worker"
  type = set(string)
  default = [ "ctx-worker-01","ctx-worker-02","ctx-worker-03" ]
}