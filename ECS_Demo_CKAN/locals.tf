locals {
    network_acls = {
        all = {
            rule_action = "allow"
            protocol = "-1"
            from_port = "0"
            to_port = "0"
            cidr_block = "0.0.0.0/0"
        }

        http = {
            rule_action = "allow"
            protocol = "tcp"
            from_port = "80"
            to_port = "80"
            cidr_block = "0.0.0.0/0"
        }

        https = {
            rule_action = "allow"
            protocol = "tcp"
            from_port = "443"
            to_port = "443"
            cidr_block = "0.0.0.0/0"
        }
    }

    zone_map = { a = 0, b = 1}
    ckan = {
        default = {
            name = "ckan"
            zones = formatlist("%s%s", var.region, keys(local.zone_map))
            rds_username = var.rds_username
            rds_password = var.rds_password
            single_nat_gateway = true
            cidr = "10.2.0.0/16"
            desired_capacity_ckan = 1
            desired_capacity_datapusher = 1
            desired_capacity_solr = 1
        }
    }
}