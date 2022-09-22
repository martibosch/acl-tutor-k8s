output "database_cluster" {
  value     = digitalocean_database_cluster.database_cluster
  sensitive = true
}

output "root_username" {
  value     = digitalocean_database_cluster.database_cluster.user
  sensitive = true
}

output "root_password" {
  value     = digitalocean_database_cluster.database_cluster.password
  sensitive = true
}

output "host" {
  value = digitalocean_database_cluster.database_cluster.host
}

output "port" {
  value = digitalocean_database_cluster.database_cluster.port
}

output "connection_string" {
  value = digitalocean_database_cluster.database_cluster.uri
}

output "instances" {
  value = {
    for user in var.users :
    user => {
      username = user
      password = digitalocean_database_user.database_users[user].password
      database = digitalocean_database_db.databases[user].name
    }
  }
}
