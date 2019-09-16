resource "aws_default_vpc" "main" {}

resource "aws_default_subnet" "main" {
  availability_zone = each.value
  for_each          = toset(data.aws_availability_zones.available.names)
}
