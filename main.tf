provider "aws" {
  region     = "us-east-1"
  
}

resource "aws_vpc" "test" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "test"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.test.id
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"
  }

}

resource "aws_s3_bucket" "atlantis_bucket" {
  bucket = "atlantis-bucket99067"
  acl = "private"

  versioning {
    enabled = true
  }
  
}
terraform {
    backend "s3" {
        bucket = "omolades3bucket"
        key    = "terraform.tfstate"
        region     = "us-east-1"
        dynamodb_table  = "dynamodb-state-locking"
   }
}

# statelock created