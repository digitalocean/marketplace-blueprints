data "template_file" "cloud-init-yaml" {
  template = file("./files/cloud-init.yaml")
  vars = {
    kibana_pass = random_password.password.result
  }
}
