terraform {
  required_version = ">= 1.5.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.37"
    }
  }
  cloud {
    organization = "Univer"
    workspaces {
      name = "devops-exam-task1"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {
  type      = string
  sensitive = true
}

variable "prefix" {
  type    = string
  default = "chernii-0704"
}

variable "region" {
  type    = string
  default = "fra1"
}

resource "digitalocean_vpc" "main" {
  name     = "${var.prefix}-vpc"
  region   = var.region
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "node" {
  name     = "${var.prefix}-node"
  region   = var.region
  size     = "s-2vcpu-4gb"
  image    = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.main.id
  ssh_keys = [data.digitalocean_ssh_key.mykey.id]
  tags     = ["${var.prefix}-node"]
}

resource "digitalocean_firewall" "main" {
  name        = "${var.prefix}-firewall"
  droplet_ids = [digitalocean_droplet.node.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8000-8003"
    source_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0"]
  }
}

data "digitalocean_ssh_key" "mykey" {
  name = "chernii-key"
}

resource "digitalocean_spaces_bucket" "main" {
  name   = "${var.prefix}-bucket"
  region = var.region
  acl    = "private"
}
