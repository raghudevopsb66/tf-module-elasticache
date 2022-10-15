resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.env}-redis"
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.instance_class
  num_cache_nodes      = var.instance_count
  parameter_group_name = aws_elasticache_parameter_group.main.name
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  port                 = 6379
  security_group_ids   = [aws_security_group.main.id]
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.env}-redis"
  subnet_ids = var.db_subnets_ids

  tags = {
    Name = "${var.env}-redis"
  }
}

resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.env}-redis"
  family = "redis6.x"
}

resource "aws_security_group" "main" {
  name        = "${var.env}-redis"
  description = "${var.env}-redis"
  vpc_id      = var.vpc_id

  ingress {
    description = "REDIS"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-redis"
  }
}

resource "aws_ssm_parameter" "elasticache" {
  name  = "immutable.elasticache.${var.env}.REDIS_HOST"
  type  = "String"
  value = aws_elasticache_cluster.main.cache_nodes[0].address
}
