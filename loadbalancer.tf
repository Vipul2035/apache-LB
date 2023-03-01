## Create L-B 
resource "aws_alb" "alb" {
  name            = "terraform-example-alb"
  security_groups = [aws_security_group.sg.id]
  subnets         = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]
  
  tags = {
    Name = "terraform-example-alb"
  }
  depends_on = [aws_instance.web]
}
## Target group
resource "aws_alb_target_group" "group" {
  name     = "alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id
  
}
 


## listener 
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_alb_target_group.group.arn
  target_id        = aws_instance.web.id
  port             = 80
}